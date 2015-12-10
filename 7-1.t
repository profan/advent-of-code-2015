#!/usr/bin/env terra

-- Terra is backwards compatible with C
-- we'll use C's io library in our example.
C = terralib.includec("stdio.h")

local function compile(file)

	local function parse(f)

		local function is_num_lit(str)
			return tonumber(str) ~= nil
		end

		local stmts = {}

		for line in io.lines(f) do

			local stmt = {}
			local main_pat = "([^-]*)-> (.*)"
			local bin_pat = "([^%u]*) ?(%u*) ?([^%u]*)"
			local body, var_name = string.match(line, main_pat)
			local left_op, op, right_op = string.match(body, bin_pat)

			stmt.lhs = var_name
			stmt.rhs = {lhs = {left_op, lit = is_num_lit(left_op)}, op = op, rhs = {right_op, lit = is_num_lit(right_op)}}
			table.insert(stmts, stmt)

		end

		return stmts

	end

	local function read(input)

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
	
		local stmts = terralib.newlist()
		symbols.stmts = stmts

		for i, node in pairs(input) do

			local target = symbols:add_if_new(node.lhs)
			local op = node.rhs.op
			local stmt

			if op == "NOT" then -- unary op
				local rhs = symbols:add_if_new(node.rhs.rhs[1])
				stmt = quote target = not rhs end
			end

			if node.rhs.lhs and node.rhs.rhs then
				local lhs = (node.rhs.lhs.lit and loadstring(node.rhs.lhs[1])) or symbols:add_if_new(node.rhs.lhs[1])
				local rhs = (node.rhs.rhs.lit and loadstring(node.rhs.rhs[1])) or symbols:add_if_new(node.rhs.rhs[1])
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

			if op == nil then -- is 123 -> x
				stmt = quote [target] = [loadstring(node.rhs.lhs)] end
			end

			stmts:insert(stmt)

		end

		return stmts

	end

	return terra()
		[read(parse(file))]
	end

end

compile('7.input')()
