-- analog_shift_register.lua

local AnalogShiftRegister = {}
AnalogShiftRegister.__index = AnalogShiftRegister

--- Creates a new Analog Shift Register.
-- @param num_stages The number of stages (or "buckets") in the register.
-- @return A new AnalogShiftRegister object.
function AnalogShiftRegister.new(num_stages)
  local self = setmetatable({}, AnalogShiftRegister)
  self.stages = {}
  self.num_stages = num_stages or 4 -- Default to 4 stages if not specified
  for i = 1, self.num_stages do
    self.stages[i] = 0.0 -- Initialize all stages to a default "analog" value
  end
  return self
end

--- Shifts all values in the register by one position and inputs a new value at the first stage.
-- This is the core function that mimics the "clock" or "trigger" of a hardware ASR.
-- @param input_value The new "analog" value to be inserted into the first stage.
function AnalogShiftRegister:shift(input_value)
  -- Shift existing values down the register
  for i = self.num_stages, 2, -1 do
    self.stages[i] = self.stages[i - 1]
  end
  -- Insert the new value at the first stage
  self.stages[1] = input_value
end

--- Returns the "analog" value at a specific stage.
-- @param stage_number The one-based index of the stage to retrieve.
-- @return The value at the specified stage, or nil if the stage is out of bounds.
function AnalogShiftRegister:get_stage(stage_number)
  return self.stages[stage_number]
end

--- Returns a table containing the values of all stages.
-- @return An array-like table of all stage values.
function AnalogShiftRegister:get_all_stages()
  local all_stages = {}
  for i = 1, self.num_stages do
    all_stages[i] = self.stages[i]
  end
  return all_stages
end

--- Prints the current state of the shift register to the console.
function AnalogShiftRegister:print_stages()
  local output = "ASR Stages: | "
  for i = 1, self.num_stages do
    output = output .. string.format("%.2f", self.stages[i]) .. " | "
  end
  print(output)
end

return AnalogShiftRegister