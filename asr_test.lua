-- asr_test.lua

-- Assuming 'analog_shift_register.lua' is in the same directory
local ASR = require('analog_shift_register')

-- Create a new analog shift register with 5 stages
local my_asr = ASR.new(5)

print("Initial state:")
my_asr:print_stages()

-- Let's simulate a sequence of incoming "analog" values and shift the register

print("\n--- Shifting in new values ---")

my_asr:shift(0.75)
my_asr:print_stages()

my_asr:shift(-0.5)
my_asr:print_stages()

my_asr:shift(1.0)
my_asr:print_stages()

my_asr:shift(0.2)
my_asr:print_stages()

my_asr:shift(-0.9)
my_asr:print_stages()

-- At this point, the register is full. Shifting again will push the oldest value out.
print("\n--- Register is full, shifting again ---")
my_asr:shift(0.05)
my_asr:print_stages() -- The initial 0.75 is now gone

-- You can access individual stage values at any time
print("\n--- Accessing individual stages ---")
local stage3_value = my_asr:get_stage(3)
print("Value at stage 3: " .. tostring(stage3_value))

local all_values = my_asr:get_all_stages()
print("All stage values:")
for i, value in ipairs(all_values) do
  print("  Stage " .. i .. ": " .. value)
end