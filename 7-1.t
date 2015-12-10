#!/usr/bin/env terra

-- Terra is backwards compatible with C
-- we'll use C's io library in our example.
C = terralib.includec("stdio.h")

-- This top-level code is plain Lua code.
local function compile(file)

	local function parse(f)

		local stmts = {}

		for line in io.lines(f) do

			local stmt = {}
			local main_pat = "([^-]*)-> (.*)"
			local bin_pat = "([^%u]*) (%u*) ([^%u]*)"
			local body, var_name = string.match(line, main_pat)
			local left_op, op, right_op = string.match(body, bin_pat)

			stmt.lhs = var_name
			stmt.rhs = {lhs = left_op, op = op, rhs = right_op}
			table.insert(stmts, stmt)

		end

		return stmts

	end

	local function read(input)

		local function add_if_new(t, name)

			if not t[name] then
				local new_symbol = symbol(uint16, name)
				t[name] = new_symbol
				return new_symbol
			else
				return t[name]
			end

		end
	
		local symbols = {} -- declared symbols go here!
		local stmts = terralib.newlist()

		for i, node in pairs(stmts) do

			local target = add_if_new(symbols, node.lhs)
			local op = node.rhs.op
			local stmt

			if op == "NOT" then -- unary op
				local rhs = add_if_new(symbols, node.rhs.rhs)
				stmt = quote target = not rhs end
			end

			if node.rhs.lhs and node.rhs.rhs then

				local lhs = add_if_new(symbols, node.rhs.lhs)
				local rhs = add_if_new(symbols, node.rhs.rhs)

				if op == "AND" then
					stmt = quote target = lhs and rhs end
				elseif op == "LSHIFT" then
					stmt = quote target = lhs << rhs end
				elseif op == "RSHIFT" then
					stmt = quote target = lhs >> rhs end
				end

			end

			if op == nil then -- is 123 -> x
				stmt = quote add_if_new(symbols, node.rhs.lhs) end
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
