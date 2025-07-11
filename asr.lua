engine.name = "PolySine"
MusicUtil = require("musicutil")
local lfos = require 'lfo'
local ASR = include("lib/analog_shift_register")

local my_asr = ASR.new(3)
  myclock = {}
  my_lfo = {}
  mod_lfo = {}
  base_hz = 100
  my_lfo_value = {}
  encoder1_value = 0
  encoder2_value = 0
  encoder3_value = 0

function init()
-- Configure the LFOS
  my_lfo = lfos:add{
    shape = 'sine',
    min = 0, -- Minimum voltage
    max = 12,   -- Maximum voltage
    offset = 5,
    depth = 0.08, -- depth (0 to 1)
    period = 0.21 -- period (in 'clocked' mode, represents beats)
    -- pass our 'scaled' value (bounded by min/max and depth) to the engine:
  }

  mod_lfo = lfos:add{
    shape = 'sine',
    min = 0.01,
    max = 5,
    depth = 0.5,
    period = 1,
    action = function(scaled)
      my_lfo:set('period', scaled)
    end
  }

  -- 3. Configure the metro to be our clock
  myclock = metro.init()
  myclock.time = 0.1
  myclock.event = track_and_shift
  --my_asr:print_stages()
  
  -- 4. Start the LFO, mod LFO and the metro clock
  my_lfo:start()
  mod_lfo:start()
  myclock:start()
  
-- Parameters Control Specs

  level_control_mod_lfo_depth = controlspec.def{
    min=0, -- 'min' is the minimum value this control can reach
    max=1, -- 'max' is the maximum value this control can reach
    warp='lin', -- 'warp' shapes the incoming data (options: 'exp', 'db', 'lin')
    step=0.01, -- 'step' is the multiple this control value will be rounded to
    default=0.5, -- 'default' is the control's initial value (clamped to min / max and rounded to 'step')
    quantum=0.01, -- 'quantum' is the fraction to apply to a received delta (eg. 0.01 will increase/decrease value by 1% of the min/max range)
    wrap=false, -- 'wrap' will wrap increments/decrements around the min / max, rather than stop at min / max
 --   units='%' -- 'units' is a string to display at the end of the control
  }
  level_control_period = controlspec.def{
    min=0.01, -- 'min' is the minimum value this control can reach
    max=5, -- 'max' is the maximum value this control can reach
    warp='lin', -- 'warp' shapes the incoming data (options: 'exp', 'db', 'lin')
    step=0.01, -- 'step' is the multiple this control value will be rounded to
    default=0.25, -- 'default' is the control's initial value (clamped to min / max and rounded to 'step')
    quantum=0.01, -- 'quantum' is the fraction to apply to a received delta (eg. 0.01 will increase/decrease value by 1% of the min/max range)
    wrap=false, -- 'wrap' will wrap increments/decrements around the min / max, rather than stop at min / max
  --  units='%' -- 'units' is a string to display at the end of the control
  }

  -- The lfo should have a range of five octaves, from 0 to five. 0 should equal the base frequency of the oscillators.
  -- depth is relative to the min/max setting of the lfo initiazation. 
  level_control_depth = controlspec.def{
    min=0.01, -- 'min' is the minimum value this control can reach
    max=0.35, -- 'max' is the maximum value this control can reach
    warp='lin', -- 'warp' shapes the incoming data (options: 'exp', 'db', 'lin')
    step=0.01, -- 'step' is the multiple this control value will be rounded to
    default=0.09, -- 'default' is the control's initial value (clamped to min / max and rounded to 'step')
    quantum=0.01, -- 'quantum' is the fraction to apply to a received delta (eg. 0.01 will increase/decrease value by 1% of the min/max range)
    wrap=false, -- 'wrap' will wrap increments/decrements around the min / max, rather than stop at min / max
 --   units='%' -- 'units' is a string to display at the end of the control
  }

  -- add parameters
  params:add_control('mod_lfo_depth','mod lfo depth',level_control_mod_lfo_depth)
  params:add_control('level_2','level 2',level_control_period)
  params:add_control('level_3','level 3',level_control_depth)


--------------Octave Control and MusicUtil--------------------
octave1 = 1
octave2 = 2
octave3 = 1

-- musicutil.generate_scale (root_num, scale_type[, octaves])
my_scale = MusicUtil.generate_scale(1, 'Six Tone Symmetrical', 5)
-- TODO: make the scale a parameter
scales = {
    "Major",
    "Natural Minor",
    "Harmonic Minor",
    "Melodic Minor",
    "Dorian",
    "Phrygian",
    "Lydian",
    "Mixolydian",
    "Locrian",
    "Whole Tone",
    "Major Pentatonic",
    "Minor Pentatonic",
    "Major Bebop",
    "Altered Scale",
    "Dorian Bebop",
    "Mixolydian Bebop",
    "Blues Scale",
    "Diminished Whole Half",
    "Diminished Half Whole",
    "Neapolitan Major",
    "Hungarian Major",
    "Harmonic Major",
    "Hungarian Minor",
    "Lydian Minor",
    "Neapolitan Minor",
    "Major Locrian",
    "Leading Whole Tone",
    "Six Tone Symmetrical",
    "Balinese",
    "Persian",
    "East Indian Purvi",
    "Oriental",
    "Double Harmonic",
    "Enigmatic",
    "Overtone",
    "Eight Tone Spanish",
    "Prometheus",
    "Gagaku Rittsu Sen Pou",
    "In Sen Pou",
    "Okinawa",
    "Chromatic"
}

  -- common redraw metronome utility:
  screen_dirty = false
  redraw_screen = clock.run(
    function()
      while true do
        clock.sleep(1/15)
        if screen_dirty then
          redraw()
          screen_dirty = false
        end
      end
    end
  )
  
  key1_down = false -- we'll use key1's state to send either coarse or fine-tune changes
  norns.enc.accel(1,true) -- add resistence to encoder 1's initial turn
  norns.enc.sens(3,10) -- add resistence to encoder 3's turns

end
-- end init()

function redraw()
  screen.clear()
  screen.level(15)
  screen.move(0,10)
  screen.text("mod lfo depth: "..params:string('mod_lfo_depth'))
  screen.move(0,35)
  screen.text("lfo speed: "..params:string('level_2'))
  screen.move(0,60)
  screen.text("lfo depth: "..params:string('level_3'))
  screen.update()
end


function key(n,z)
  -- short way:
  if n == 1 then
    key1_down = z == 1 and true or false 
  end
 end

function enc(n,d)
  if n == 1 then
    if key1_down then
-- TODO add other parameter to control 
    else
      params:delta('mod_lfo_depth',d)
      mod_lfo:set('depth', params:get('mod_lfo_depth'))
    end
  elseif n == 2 then
    if key1_down then
-- TODO add other parameter to control  
    else
      params:delta('level_2',d)
    --  print(params:get('level_2')) -- print the current value of level_2
      my_lfo:set('period', params:get('level_2')) -- set the LFO depth to the value of level_2
    end
  elseif n == 3 then
    if key1_down then
 -- TODO add other parameter to control  
    else
      params:delta('level_3',d)
   --   print("depth" .. params:get('level_3')) -- print the current value of level_3
      my_lfo:set('depth', params:get('level_3')) -- set the LFO depth to the value of level_3
    end
  end

  screen_dirty = true

end

function track_and_shift()
    -- Get the current value from the LFO
    my_lfo_value = my_lfo:get('scaled')
    print("lfo scaled " .. my_lfo:get('scaled'))
    local value_to_shift = mapFloatToInteger(my_lfo_value)
    -- Use that value as the input to the shift register
    local frequency =  MusicUtil.snap_note_to_array(value_to_shift, my_scale)
    my_asr:shift(frequency)
    local stage1_value = (my_asr:get_stage(1) * octave1)
    local stage2_value = (my_asr:get_stage(2) * octave2)
    local stage3_value = (my_asr:get_stage(3) * octave3)
   
    engine.hz1(stage1_value * base_hz) -- Scale the value to a frequency
    engine.hz2(stage2_value * base_hz) -- Scale the value to a frequency
    engine.hz3(stage3_value * base_hz) -- Scale the value to a frequency
    

    -- engine.hz(stage5_value * 440) -- Scale the value to a frequency
    -- engine.hz(stage6_value * 440) -- Scale the value to a frequency
    -- Print the current state of all stages to the console
   -- my_asr:print_stages()
end

function mapFloatToInteger(value)
  -- Handle the upper boundary explicitly. If the value is exactly 1.0,
  -- it should map to the highest integer, 12.
  if value == 1.0 then
    return 12
  end

  -- For all other values in the range [0.0, 1.0), this formula works.
  -- 1. Multiply the value by 12 to scale it to the range [0.0, 12.0).
  -- 2. Use math.floor() to get the integer part, resulting in a value from 0 to 11.
  -- 3. Add 1 to shift the range to [1, 12].
  return math.floor(value * 12) + 1
end


-- ===================================================================
--  2. MODIFIED LOOKUP FUNCTION
-- ===================================================================

---
-- Retrieves a frequency from the CMajorScaleHz table using a numerical index.
-- If the index is > 8, it finds the correct note in the base octave and
-- multiplies its frequency by 2 for each additional octave.
--
-- @param scaleIndex (integer) The index of the note in the scale (e.g., 1, 5, 9, 17...). Must be > 0.
-- @return (number or nil) The frequency in Hz if the index is valid, otherwise nil.
--
function getFrequencyByIndex(scaleIndex)
  -- Validate that the index is a positive number


  local scaleSize = #CMajorScaleNoteOrder

  -- Step 1: Find the corresponding index within the base octave (1-8).
  -- We use the modulo operator. `(scaleIndex - 1)` converts to 0-based for the
  -- calculation, and `+ 1` converts back to 1-based for Lua table indexing.
  local baseIndex = (scaleIndex - 1) % scaleSize + 1

  -- Step 2: Determine how many octaves to shift up.
  -- For indices 1-8, octaveShift will be 0.
  -- For indices 9-16, octaveShift will be 1, etc.
  local octaveShift = math.floor((scaleIndex - 1) / scaleSize)

  -- Step 3: Get the base note and its frequency from the original tables.
  local baseNoteName = CMajorScaleNoteOrder[baseIndex]
  local baseFrequency = CMajorScaleHz[baseNoteName]

  -- This should only happen if the tables are malformed, but it's safe to check.
  if not baseFrequency then
      return nil
  end

  -- Step 4: Calculate the final frequency.
  -- Multiplying a frequency by 2 raises it by one octave.
  -- We use `2^octaveShift` to handle multiple octave shifts.
  -- (e.g., 2^0=1 for no change, 2^1=2 for one octave, 2^2=4 for two octaves).
  local finalFrequency = baseFrequency * (2^octaveShift)

  return finalFrequency
end


function cleanup()
  myclock:stop()
  my_lfo:stop()
  mod_lfo:stop()
  print("Shift register clock stopped.")
end