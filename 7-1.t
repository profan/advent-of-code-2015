#!/usr/bin/env terra

-- Terra is backwards compatible with C
-- we'll use C's io library in our example.
C = terralib.includec("stdio.h")

local function compile(file, part)

	local function parse(f)

		local function is_num_lit(str) return tonumber(str) ~= nil end
		local stmts = {}

		for line in io.lines(f) do

			local stmt = {}
			local main_pat = "([^-]*)-> (%l*)"
			local bin_pat = "([^%u]*) ?(%u*) ?([^%u]*)"
			local body, var_name = string.match(line, main_pat)
			local left_op, op, right_op = string.match(body:gsub("%s+", ""), bin_pat)

			stmt.lhs = var_name
			stmt.rhs = {lhs = {left_op, lit = is_num_lit(left_op)}, op = op, rhs = {right_op, lit = is_num_lit(right_op)}}
			table.insert(stmts, stmt)

		end

		table.sort(stmts, function(a, b)
			if (#a.lhs < #b.lhs) then 
				return true
			elseif (#a.lhs > #b.lhs) then
				return false
			end
			return a.lhs < b.lhs
		end)

		return stmts

	end

	local function read(input, override)

		local symbols = {} -- declared symbols go here!
		function symbols:add_if_new(name)
			if not self[name] then
				local new_symbol = symbol(uint16, name)
				self:declare(new_symbol, name)
				self[name] = new_symbol
				return new_symbol
			else
				return self[name]
			end
		end

		function symbols:declare(sym, name)
			local declaration = quote var [sym] : uint16 = 0 end
			self.stmts:insert(declaration)
		end
	
		local function sym_or_lit(thing) return (thing.lit and tonumber(thing[1])) or symbols:add_if_new(thing[1]) end
		local stmts = terralib.newlist()
		symbols.stmts = stmts
		local saved_a

		for i, node in pairs(input) do
			
			local target = symbols:add_if_new(node.lhs)
			local op = node.rhs.op
			local stmt

			if op == "NOT" then -- unary op
				local rhs = symbols:add_if_new(node.rhs.rhs[1])
				stmt = quote [target] = not rhs end
			end

			if node.rhs.lhs[1] ~= "" and node.rhs.rhs[1] ~= "" then
				local lhs = sym_or_lit(node.rhs.lhs)
				local rhs = sym_or_lit(node.rhs.rhs)
				if op == "AND" then
					stmt = quote [target] = [lhs] and [rhs] end
				elseif op == "OR" then
					stmt = quote [target] = [lhs] or [rhs] end
				elseif op == "LSHIFT" then
					stmt = quote [target] = [lhs] << [rhs] end
				elseif op == "RSHIFT" then
					stmt = quote [target] = [lhs] >> [rhs] end
				end
			end

			if op == "" then -- is 123/some_var -> x
				local s = (node.lhs == "b" and override) or sym_or_lit(node.rhs.lhs)
				stmt = quote [target] = [s] end
			end

			if (node.lhs == "a") then saved_a = stmt
			else stmts:insert(stmt) end

		end

		stmts:insert(saved_a)
		stmts:insert(quote return [symbols["a"]] end)

		return stmts

	end

	if (part == "1") then
		return terra()
			[read(parse(file))]
		end
	else
		return terra(override : int)
			[read(parse(file), override)]
		end
	end

end

run1 = compile('7.input', "1")
last_result = run1()
print("part 1 - a: " .. last_result)

run2 = compile('7.input', "2")
print("part 2 - a: " .. run2(last_result))
