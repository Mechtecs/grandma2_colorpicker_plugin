--[[
This plugin is written by Egidius Mengelberg

It enables you to automaticly make a HighFX and LowFX preset to use in your effects

The buttons are created in their own layout view, including the assigned images
(same method as the automated layout view of the ColorPicker plugin by Leon Reucher).
--]]


--USER CONFIG

-- Numbers of color preset Pool Items
local cNum = {1,2,3,4,5,6,7,8,9,10,11,12}

local macStart = 1200  --starting macro pool item to be stored to
local seqStart = 200   --starting sequence number to be stored to
local startingPg = 2 --page to start
local startingExec = 161 --fader to start
local LowFXPreset = 112 -- Low fx pool item
local HighFXPreset = 113 -- High fx pool item

--layout view config (use a different layout view than the ColorPicker plugin)
local layoutView = 2
local layoutName = 'HighLowFX'
local startX = 0.5
local startY = 0.5
local layoutSpacing = 0.1

local imageStart = 544
local imageSpaceBetween = 4

-- Colors from Swatch Book (to change Appearance of Macro to this color)
local colSwatchBook = {'White', 'Red', 'Orange', 'Yellow', 'Green', 'Sea Green', 'Cyan', 'Lavender', 'Blue', 'Violet', 'Magenta', 'Pink'}

-- Filed images
local filledImages = {304,305,306,307,308,309,310,311,312,313,314,315}

-- Unfiled images
local unfilledImages = {320,321,322,323,324,325,326,327,328,329,330,331}
local imageGrid = {}

-- Image grid


-- END USER CONFIG

--local shortcut variables
local text = gma.textinput
local cmd = gma.cmd
local getHandle = gma.show.getobj.handle
local xmlfile


--FUNCTIONS
function getLabel(str)
  return gma.show.getobj.label(getHandle(str))
end


function getClass(str)
  return gma.show.getobj.class(getHandle(str))
end

function macStore(macroNum, label) --generate macro
  gma.cmd('Store Macro 1.'..macroNum) --create macro
  gma.cmd('Label Macro 1.'..macroNum..' \"'..label..'\"') --label the macro
end



function macLine(macroNum, lineNum, command, wait) --generate new line within macro
  cmd('Store Macro 1.'..macroNum..'.'..lineNum)
  cmd('Assign Macro 1.'..macroNum..'.'..lineNum..'/cmd = \"'..command..'\"')
  if wait then cmd('Assign Macro 1.'..macroNum..'.'..lineNum..'/wait = \"'..wait..'\"') end
end

--Escape a string for use in an XML attribute
function xmlEscape(str)
  return (tostring(str):gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'))
end

--Absolute path of a file in the importexport folder (works on console (Linux) and onPC (Windows))
function importExportPath(filename)
  local slash = package.config:sub(1, 1)
  return gma.show.getvar('PATH')..slash..'importexport'..slash..filename
end

--Import a layout view xml from the internal drive.
--The Import command reads from the currently selected drive, which may be a USB stick.
function importLayout(filename, index)
  cmd('SelectDrive 1')
  cmd('Import \"'..filename..'\" At Layout '..index..' /nc')
end

function printNewButton(x, y, imgName, imgIndex, macroIndex, label)
  imgName = xmlEscape(imgName)
  label = xmlEscape(label)
  xmlfile:write('\t\t\t\t<LayoutCObject font_size="Small" center_x="'..x..'" center_y="'..y..'" size_h="1" size_w="1" background_color="3c3c3c" border_color="5a5a5a" icon="None" show_dimmer_bar="Off" show_dimmer_value="Off" function_type="Simple" select_group="1">', "\n")
  xmlfile:write('\t\t\t\t\t<image name="'..imgName..'">', "\n")
  xmlfile:write('\t\t\t\t\t\t<No>8</No>', "\n")
  xmlfile:write('\t\t\t\t\t\t<No>'..imgIndex..'</No>', "\n")
  xmlfile:write('\t\t\t\t\t</image>', "\n")
  xmlfile:write('\t\t\t\t\t<CObject name="'..label..'">', "\n")
  xmlfile:write('\t\t\t\t\t\t<No>13</No>', "\n")
  xmlfile:write('\t\t\t\t\t\t<No>1</No>', "\n")
  xmlfile:write('\t\t\t\t\t\t<No>'..macroIndex..'</No>', "\n")
  xmlfile:write('\t\t\t\t\t</CObject>', "\n")
  xmlfile:write('\t\t\t\t</LayoutCObject>', "\n")
end

function printXmlStart(index, name)
  xmlfile:write('<?xml version="1.0" encoding="utf-8"?>', "\n")
  xmlfile:write('<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.9.60/MA.xsd" major_vers="3" minor_vers="9" stream_vers="60">', "\n")
  xmlfile:write('\t<Info datetime="'..os.date('%Y-%m-%dT%H:%M:%S')..'" showfile="'..xmlEscape(gma.show.getvar('SHOWFILE') or '')..'" />', "\n")
  xmlfile:write('\t<Group index="'..index..'" name="'..xmlEscape(name)..'">', "\n")
  xmlfile:write('\t\t<LayoutData index="0" marker_visible="true" background_color="000000" visible_grid_h="1" visible_grid_w="0" snap_grid_h="0.5" snap_grid_w="0.5" default_gauge="Filled &amp; Symbol" subfixture_view_mode="DMX Layer">', "\n")
  xmlfile:write('\t\t\t<CObjects>', "\n")
end

function printXmlEnd()
  xmlfile:write('\t\t\t</CObjects>', "\n")
  xmlfile:write('\t\t</LayoutData>', "\n")
  xmlfile:write('\t</Group>', "\n")
  xmlfile:write('</MA>', "\n")
end

return function()
-----------------------------------------------------------------
--------------------- START OF PLUGIN ---------------------------
-----------------------------------------------------------------

local xmlFilename = 'highlowfx_layout.xml'
local xmlError
xmlfile, xmlError = io.open(importExportPath(xmlFilename), 'w')
if not xmlfile then
  gma.feedback('HighLowFX: cannot write layout file: '..tostring(xmlError))
  gma.echo('HighLowFX: cannot write layout file: '..tostring(xmlError))
  return
end
printXmlStart(layoutView, layoutName)

local imageCurrent = imageStart

for r=1,2 do
   for c=1,#cNum do
      if c == 1 then
        imageGrid[r] = {}
      end

      imageGrid[r][c] = imageCurrent
      cmd('Copy Image '..unfilledImages[c]..' At '..imageGrid[r][c]..' /m /nc')

      imageCurrent = imageCurrent + 1
   end
   imageCurrent = imageCurrent + imageSpaceBetween
end

local cName = {} --list where names of preset pool items will be stored

-- get the name of the according number of preset
for c=1,#cNum do
  cName[c] = getLabel('Preset 4.'..cNum[c])
  gma.feedback('Color with number '..cNum[c]..' found')
  if (not cName[c]) then cName[c] = 'Color '..cNum[c] end
  gma.feedback('Label '..cName[c]..' assigned')
end

--PRESETS TO SEQUENCE CUES BY GROUP AND CREATE MACROS--
local macCurrent = macStart
local seqCurrent = seqStart
local faderCurrent = startingExec

cmd('ClearAll')

local str_storeOpt = ' /use=active /so=Prog /nc'

for t=1,2 do
  for c = 1, #cNum do
    local execCurrent = tostring(startingPg..'.'..faderCurrent)
    local copyCommand = ''
    local macLabel = ''
    cmd('ClearAll')
    cmd('Store Sequence '..seqCurrent..' Cue '..c..' '..str_storeOpt) --store to sequence and cue

    if c == #cNum then
      cmd('Assign Sequence '..seqCurrent..' At Executor '..execCurrent) --assign sequence to executor
    end

    if t == 1 then
      cmd('Label Sequence '..seqCurrent..' \"Low FX\"'); --label sequence
      macLabel = 'Low FX '..cName[c]
      copyCommand = 'Copy Preset 4.'..c..' At Preset 4.'..LowFXPreset
    end

    if t == 2 then
      cmd('Label Sequence '..seqCurrent..' \"High FX\"'); --label sequence
      macLabel = 'High FX '..cName[c]
      copyCommand = 'Copy Preset 4.'..c..' At Preset 4.'..HighFXPreset
    end

    macStore(macCurrent, macLabel) --create macro; label with color name
    macLine(macCurrent, 1, 'Goto Executor '..execCurrent..' Cue '..c)
    macLine(macCurrent, 2, 'Off Macro '..macStart+(#cNum*(t-1))..' Thru '..(macStart-1)+(#cNum*(t-1))+#cNum..' - '..macCurrent)

    local imageCommand1 = 'Copy Image '..unfilledImages[1]..' Thru '..unfilledImages[#cNum]..' At '..imageGrid[t][1]..' /m /nc'
    local imageCommand2 = 'Copy Image '..filledImages[c]..' At '..imageGrid[t][c]..' /m /nc'

    cmd('Assign Sequence '..seqCurrent..' Cue '..c..' /cmd=\"'..copyCommand..' /m /nc; '..imageCommand1..' /m /nc; '..imageCommand2..'/m /nc\"')
    cmd('Label Sequence '..seqCurrent..' Cue '..c..' \"'..cName[c]..'\"');  --label cue w/ name tables


    -- change the appearance of the macro
    cmd('Appearance Macro '..macCurrent..' /color='..'"'..colSwatchBook[c]..'"')

    cmd('ClearAll'); --clear your programmer

    local posX = (c+startX) * (1+layoutSpacing)
    local posY = (t+startY) * (1+layoutSpacing)

    --add macro to the layout view
    printNewButton(posX, posY, macLabel, imageGrid[t][c], macCurrent, macLabel)

    macCurrent = macCurrent + 1 --move to next macro number
    gma.sleep(0.05) --to ease processing power conflicts

  end
  seqCurrent  = seqCurrent + 1 --move to next sequence number
  faderCurrent  = faderCurrent + 1
end


local macCurrent = macStart + (2 * #cNum) --resets variable at the position after all color macros based on the number of possible combinations

local mac_sys_start = macCurrent
local mac_uninstall = mac_sys_start + 2

local seqEnd = seqCurrent - 1 --one sequence for Low FX and one for High FX

--lock uninstall macro
macStore(macCurrent, 'DISABLE Uninstall HighLowFX Macro')
macLine(macCurrent, 1, 'Assign Macro 1.'..mac_uninstall..'.* /disabled=yes')
macLine(macCurrent, 2, 'Lock Macro '..mac_uninstall)
macCurrent = macCurrent + 1


--enable uninstall macro
macStore(macCurrent, 'ENABLE Uninstall HighLowFX Macro')
macLine(macCurrent, 1, 'Unlock Macro '..mac_uninstall)
macLine(macCurrent, 2, 'Assign Macro 1.'..mac_uninstall..'.* /disabled=no')
macCurrent = macCurrent + 1


--UNINSTALL MACRO--
macStore(macCurrent, 'UNINSTALL HighLowFX')
macLine(macCurrent, 1, 'Delete Sequence '..seqStart..' Thru '..seqEnd..' /nc')
macLine(macCurrent, 2, 'Delete Image '..imageGrid[1][1]..' Thru '..imageGrid[2][#cNum]..' /nc')
macLine(macCurrent, 3, 'Delete Layout '..layoutView..' /nc')
macLine(macCurrent, 4, 'Delete Macro '..macStart..' Thru '..macCurrent..' /nc')

cmd('Macro '..mac_sys_start) --run uninstall-lock macro

--close xml file and import it as layout view
printXmlEnd()
xmlfile:close()

importLayout(xmlFilename, layoutView)

end  --END OF PLUGIN
