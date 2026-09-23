# grandma2_colorpicker_plugin

A LUA plugin to automatically create a color picker layout view.
I also added a function to create High and Low FX presets for use in a effect engine.
This is the plugin called HighLowFX.lua.

Both plugins create their layout view automatically, including the images assigned to the macro buttons.
This method was contributed by [leonreucher251](https://github.com/leonreucher251).
The two separate versions of this plugin (with and without automatic layout view creation) have been merged into this one version.

### Be sure to first run the colorpicker and then the HighLowFX plugin! 
I have not tested it the otherway around.

## How the layout views are created
Each plugin writes its layout view as an XML file to the `importexport` folder of the show data path
(`colorpicker_layout.xml` and `highlowfx_layout.xml`) and imports it into the configured layout view.
This works on the consoles (Linux) as well as on grandMA2 onPC (Windows).

Before the import, the plugins select the internal drive (`SelectDrive 1`), because the `Import` command reads from the currently selected drive.
If a USB stick was selected before running a plugin, select it again afterwards.

The configured layout views are overwritten by the plugins.

## Configuration
In the ColorPicker.lua file, you will find the config section at the top.

With `grpNum`, you can change the groups you would like to use in your color picker.
Just edit the numbers in the array. They correspond with the group pool items.
You can add as many as you would like.

`macStart` and `seqStart` are the pool items where the plugin will start with adding all the macros and sequences.

`startingPage` and `startingFader` correspond to the page and fader where all your sequences will be stored.

`layoutView` sets the layout view where all the macros will be stored to, `layoutName` sets its name.
And `spacing` sets the space between the macros in the layout pool.

With `imgStart` you can set the image pool item where the plugin wll start copying images to.
The `allImgStart` defines the place where the images for the All macros will be stored.

`filledImages` constains an array of image pool numbers with all the filled images.
The order of these images is the same as the colors. Please read below to find out what the default order is.

`unfilledImages` contains the array of image pool numbers with all the unfilled images. 

### HighLowFX
The HighLowFX plugin creates its buttons in its own layout view, so it does not interfere with the color picker layout view.
In the HighLowFX.lua file, `layoutView` (default: 2) and `layoutName` set this layout view.
Make sure it is a different layout view than the one used by the ColorPicker plugin.
`startX`, `startY` and `layoutSpacing` set the position of the buttons in this layout view.


## Colors

The colors are in the following order:
White, Red, Orange, Yellow, Green, Seagreen, Cyan, Blue, Lavender, Violet, Magenta, Pink.


## Images 
The images folder contains all the images you can use in this plugin.


## Further development

Because I am a very busy student I haven't got much time to develop this plugin. I will put in time when I can! 

### Next Features

1. Making sure it works with different colors.
2. An overall code cleanup
