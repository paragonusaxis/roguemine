StateMachine = Class{}

function StateMachine:init(states)
	self.empty = {
		render = function() end,
		update = function() end,
		enter = function() end,
		exit = function() end
	}
	self.states = states or {} -- [name] -> [function that returns states]
	self.current = self.empty
	self.currentStateName = 'empty'
end

function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName]) -- state must exist!
	self.current:exit()
	self.current = self.states[stateName]()
	self.currentStateName = stateName
	-- self:printState()
	self.current:enter(enterParams)
end

function StateMachine:isState(stateName)
	if stateName == self.currentStateName then
		return true
	end

	return false
end

function StateMachine:printState()
	print(self.currentStateName)
end

function StateMachine:update(dt)
	self.current:update(dt)
end

function StateMachine:render()
	self.current:render()
end