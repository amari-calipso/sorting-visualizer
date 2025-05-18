# Sorting Visualizer
## NOTE: This project is no longer maintained, check out https://github.com/amari-calipso/UniV

 A sorting algorithms visualizer written in opal

to run from source, open or compile `SortingVisualizer.opal` using the opal compiler.

to build a release, use `opal release build.iproj` or `opal release build_dev.iproj` depending on which version you want to build.

here you can find a video about the program: https://youtu.be/iZjOP4Htz3c

# Installation
To properly run the visualizer from source, you will need to install the Python modules listed in `requirements.txt`.

To use render mode, ffmpeg needs to be properly installed on your system.

# Usage
The visualizer consists of three main menus:
- Run sort: Lets you pick all settings to run a specific sort and visualize it;
- Run all sorts: Lets you pick a distribution, shuffle, and visual style to run every sort on. This is the mode that's used to create videos such as [the example](https://youtu.be/iZjOP4Htz3c);
- Threads: 
	- Threads are sequences of actions that are defined through the thread builder, useful to make videos about a certain topic or algorithm. The "Threads" menu has two submenus:
		- Run threads: Runs a thread that's been previously created;
		- Thread builder: Enables the user to create threads;

While an algorithm is running, the "S" key on your keyboard can be pressed to skip it.

# Settings
### Show text
If set to `False`, the visualizer will hide the text in the top left corner.
### Show auxiliary array
If set to `False`, auxiliary arrays will not be visualized.
### Show internal information
If set to `True`, additional information about the visualizer's state will be visualized in the top left text.
### Render mode
If set to `True`, the visualizer will generate videos instead of visualizing algorithms in real-time. A preview of the video will be visualized on the screen while it's being made, at a lower framerate.
### Lazy auxiliary visualization
The visualizer checks if the auxiliary array changed in size, or its maximum element changed, in specific scenarios, so that the visual can re-compute its data accordingly. If lazy auxiliary visualization is set to `True`, these checks are disabled, that is, the visualizer will assume the maximum element of the auxiliary array and its length are constant.
### Lazy rendering
Real-time visualization will try to use `fast` or `selective` variants of the given visual style for performance reasons in favorable scenarios, while render mode always uses standard variants, which are higher quality, but slower in those same scenarios. If lazy rendering is set to `True`, the visualizer will try to use `fast` or `selective` variants of visual styles for render mode too. This does not result in quality loss in certain cases, and can be used for quick videos.
### Render bitrate (kbps)
Sets the output video bitrate (in kbps) for videos generated through render mode.
### Render profile
Allows the user to select one of the different encoding profiles to be used with ffmpeg in render mode. Such profiles are found in the `profiles` folder, and can be added and customized dynamically. Note that some of these profiles are platform or hardware dependent, so they're not guaranteed to work. In case an incompatible profile or invalid options have been provided through the selected profile, or something went wrong during the rendering process, the visualizer will report that ffmpeg exited with a nonzero return code.

# Creating Python extensions
To do Python development to add modules for the visualizer, it's sufficient do download a release version and add your modules in the `external` folder. Development releases (marked as `dev`) are available and provide Python definitions for the program's API.

When adding modules to the visualizer dynamically (through the `external` folder), you can use the Python definitions like this:
```py
from typing import TYPE_CHECKING

if TYPE_CHECKING:
	from SortingVisualizer import *
```

This way, your IDE will be able to typecheck the program and give you proper hints, while not executing the import when the code is actually ran.

If you're working directly with the source code, you can create the Python definitions yourself. To do this, it's sufficient to compile `SortingVisualizer.opal` in Python mode, like this:
```
opal pycompile SortingVisualizer.opal
```

Note that all visual styles and sound systems added through the `external` folder have to be marked as `@SortingVisualizer.external` for them to be recognized. For example:
```py
@SortingVisualizer.external
class MyVisual(Visual):
	...

@SortingVisualizer.external
class MySound(Sound):
	...
```

Other types of extensions don't require this. 

If you are writing code that will be embedded in the compiled visualizer (that is, not through the `external` folder), add these lines on top of your Python code:
```py
#opal$if False
from SortingVisualizer import *
#opal$end
```

These will import the visualizer normally when you're doing development, since Python will see the `#opal` lines as comments, but ignore the import when compiling the whole project, since opal will treat those lines as precompiler instructions.

# The API
## Array operations
The array provided to the algorithms is filled with instances of the `Value` class. A `Value` contains a numeric value that actually gets sorted; an index, which is used for visualization and tracking of the value inside the array; a stability index, which is used for stability checking; an `aux` flag, that marks whether the `Value` is contained in the main array, or an `aux`iliary one. An instance of `Value` acts as any sortable data type, but it will automatically track elapsed time and display highlights for the current operation. The `Value` class provides the following methods:
- `copy() -> Value`: creates a copy of the `Value` without tracking time, statistics or highlighting;
- `read() -> Value`: like `copy` but it tracks time and statistics and highlights the `Value`'s index;
- `noMark() -> Value`: creates a copy of the `Value` without the index field, causing it not to get highlighted;
- `getInt() -> int`: returns the integer value of the `Value` without tracking time, statistics or highlighting;
- `readInt() -> int`: like `getInt` but it tracks time and statistics and highlights the `Value`'s index;
- `readDigit(digitIdx: int, base: int) -> int`: returns the given `Value`'s digit in the given base;
- `readNoMark() -> Value, int`: like `read`, but the returned value becomes "invisible" (that is, it doesn't get highlighted anymore). The `Value`'s index is returned so it can be restored later;
- `write(other: Value | int)`: writes a `Value` to that `Value`'s position;
- `writeRestoreIdx(other: Value | int, idx: int)`: like `write`, but it allows to restore an index. Used in conjunction with `readNoMark`;
- `swap(other: Value)`: swaps with another `Value`.
## Manually working with statistics
To manually increment, decrement, or edit statistics, you can access:
- `sortingVisualizer.reads`;
- `sortingVisualizer.comparisons`;
- `sortingVisualizer.writes`;
- `sortingVisualizer.swaps`.

Comparisons and reads are tied together, like swaps and writes. That is, if you add one swap, two writes will be added. 
The visualizer also provides a method to time operations manually:
- `sortingVisualizer.timer(sTime: float)`

It's used in conjuction with `default_timer()` like this:
```
new float sTime = default_timer();
# perform an operation here
sortingVisualizer.timer(sTime);
```
## Manual writes
For array operations that don't work properly with the `Value` class, the visualizer provides two methods that automatically keep track of statistics and time:
- `sortingVisualizer.write(array: list, i: int, val)`;
- `sortingVisualizer.swap(array: list, a: int, b: int)`.
## Manual highlights
The visualizer provides twelve methods for manual highlighting:
- `sortingVisualizer.highlight(index: int, aux: list | None = None)`: highlights the given index;
- `sortingVisualizer.multiHighlight(indices: list[int], aux: list | None = None)`: highlights a list of indices.
- `sortingVisualizer.highlightAdvanced(index: HighlightInfo)`: highlights a `HighlightInfo` object;
- `sortingVisualizer.multiHighlightAdvanced(indices: list[HighlightInfo])`: highlights a list of `HighlightInfo` objects;
- `sortingVisualizer.queueHighlight(index: int, aux: list | None = None)`: adds the given index to the list of highlights that will be visualized with the next update;
- `sortingVisualizer.queueMultiHighlight(indices: list[int], aux: list | None = None)`: like `queueHighlight`, but accepts a list of indices;
- `sortingVisualizer.queueHighlightAdvanced(index: HighlightInfo)`: like `queueHighlight`, but uses a `HighlightInfo` object;
- `sortingVisualizer.queueMultiHighlightAdvanced(indices: list[HighlightInfo])`: like `queueHighlightAdvanced`, but accepts a list of `HighlightInfo` objects;
- `sortingVisualizer.markArray(id: Any, index: int, aux: list | None = None, color: tuple[int, int, int] | None = None)`: marks the array persistently until the end of the current algorithm. `id` can be any hashable object;
- `sortingVisualizer.markArrayAdvanced(id: Any, index: HighlightInfo)`: like `markArray`, but uses a `HighlightInfo` object;
- `sortingVisualizer.clearMark(id: Any)`: clears a mark precedently set through `markArray`, given its `id`. Throws a `VisualizerException` if the `id` of the given mark does not exist;
- `sortingVisualizer.clearAllMarks()`: clears all marks set through `markArray`.

An `HighlightInfo` object contains more information for each highlight. Internally, the visualizer also generates those when calling the non-advanced variants of highlights. They are composed like this:
`record HighlightInfo(index: int, aux: list[Value] | None = None, color: tuple[int, int, int] | None = None, silent: bool = False);`
- `index`: contains the array index to be highlighted;
- `aux`: stores a pointer to the auxiliary array where the highlight came from. If `None`, the highlight came from the main array;
- `color`: the color that the highlight will have. If `None`, the color will be set to the default highlight color for the current visual style;
- `silent`: whether the highlight should not produce sound. Useful for color coding.

For dynamic color coding, the visualizer provides a `sortingVisualizer.getColor(n: int) -> tuple[int, int, int]` method, which assigns a color dynamically to a number, as a color id.

Queued highlights are stored in a list (`sortingVisualizer.highlights`) that can be edited manually for advanced operations. In a multithreaded context, it should be edited while the relative lock (`sortingVisualizer.highlightsLock`) is acquired. This is done automatically in the `queue` methods.

## Working with auxiliary arrays
To create a new array, the visualizer provides  `sortingVisualizer.createValueArray(length: int) -> list[Value]`, which is pre-filled with already configured `Value`s. This also automatically shows the array in the visualizer. To remove an array from visualization, you can use `sortingVisualizer.removeAux(array: list)`. In case the `createValueArray` function is not used to create an array, but you still want to visualize it, you can use `sortingVisualizer.addAux(array: list)` and, if it's not an array of values, you can provide adaptation functions using `sortingVisualizer.setAdaptAux(fn, idxFn = None)`: 
- `fn(arrays: list[list]) -> list[Value]`: set this function to properly convert all the auxiliary arrays in a list of `Value`s that the visualizer can work with;
- `idxFn(idx: int, aux: list) -> int`: this function can be set to adapt the highlighted indices to the resulting `list[Value]` for visualization purposes.

You can mark arrays as not containing elements from the original array by using `sortingVisualizer.setNonOrigAux(*arrays)`, this will allow for better visualizations. Note that this method automatically marks the algorithm as [using dynamic aux](#adding-new-shuffles) since this requires dynamic computations.

Deleting an array, or making it go out of scope, while the array is being visualized, will automatically remove the array from the visualization thanks to the dedicated garbage collector.

You can also disable highlights from a given array using the `sortingVisualizer.setInvisibleArray(array: list[Value])` method.
## Using rotations and pivot selections provided by the visualizer
To fetch a specific rotation or pivot selection algorithm, `sortingVisualizer.getPivotSelection(id: Optional[int] = None, name: Optional[str] = None)` and `sortingVisualizer.getRotation(id: Optional[int] = None, name: Optional[str] = None)` can be used. You can either pass the name of the algorithm to the function, like this:
```
new auto myRotation = sortingVisualizer.getRotation(name = "Gries-Mills").indexedFn;
```
... or you can pass the ID of the algorithm of choice, mostly useful in combination with a user selection, for example:
```
new auto myPivotSelection = sortingVisualizer.getPivotSelection(
	id = sortingVisualizer.getUserSelection(
		[p.name for p in sortingVisualizer.pivotSelections],
		"Select a pivot selection algorithm: "
	)
);
```

### Rotations
Rotations provide two modes: indexed, and lengths. Indexed mode uses these types of arguments:
```
myIndexedRotation(start, middle, end);
```
While lengths mode uses these:
```
myLengthsRotation(start, lengthOfFirstSegment, lengthOfSecondSegment);
```

`sortingVisualizer.getRotation()` returns a `Rotation` object, which provides both `indexedFn`, for the indexed version of the function, and `lengthFn` for the lengths version of the function.

### Pivot Selections
Pivot Selection algorithms on the other hand, provide just one function that takes as input the start and end of the segment in which the pivot has to be selected, and return the index of the selected pivot.

`sortingVisualizer.getPivotSelection()` returns the function directly.
## Other utilities
The visualization speed can be changed through `sortingVisualizer.setSpeed(value: float)` and reset to 1 via `sortingVisualizer.resetSpeed()`. The speed can be fetched through `sortingVisualizer.speed` for temporary speed editing.

Delays can be set by using `sortingVisualizer.delay(timeMs: float)` before any highlighted operation.

Custom titles can be set through `sortingVisualizer.setCurrentlyRunning(name: str, category: Optional[str] = None)`. The category is best left untouched to avoid confusion.

The visualizer also provides methods for user input, namely:
- `sortingVisualizer.getUserInput(message: str = "", default: str = "", type_: int) -> type_`: asks the user a text input that gets converted to `type_`. `default` sets the default value;
- `sortingVisualizer.getUserSelection(content: list[str], message: str = "") -> int`: asks the user to select between a list of items and returns the selection index.

And a method for warnings and errors, often used for invalid inputs:
- `sortingVisualizer.userWarn(message: str)`.

When the process of asking the user needs to be skipped, like in a custom thread, an "autoValue" can be pushed into a queue through the `sortingVisualizer.pushAutoValue(value)` method. To remove the next value, `sortingVisualizer.popAutoValue()` can be used. `sortingVisualizer.resetAutoValues()` clears the queue.
## Adding new shuffles
Adding a new shuffle is extremely simple! You just need to add your `.opal` or `.py` file inside the `shuffles` folder, and provide a run function, composed like this:
```
@Shuffle("Shuffle Name");
new function myShuffle(array) {
    # your code here
}
```
or, in Python:
```py
@Shuffle("Shuffle Name")
def myShuffle(array):
    ... # your code here
```
An optional boolean argument called `usesDynamicAux` can be set if the shuffle uses an auxiliary array which is not static in size or maximum element, or is composed of items that don't belong in the main array. It is `False` by default.
## Adding new sorts
Like shuffles, adding sorts is very simple.  `.opal` or `.py` files need to be added to the `sorts` folder, and they have to provide a run function:
```
@Sort(
    "Sort Category",
    "Sort Name",
    "Sort Name in menu selection"
);
new function mySort(array) {
    # your code here
}
```
Like in shuffles, the sort class provides a `usesDynamicAux` argument for the same purpose. The sort class also provides an `enabled` argument, that can be set to `False` for sorts that aren't ready for use. Those sorts will only be added to the sorts list if `DEBUG_MODE` is set to `True`
## Adding new pivot selections
Pivot selections are algorithms used to select a pivot in partitioning sorts that require one. The visualizer provides a set of pivot selections for those algorithms to use, and the user can pick the one they prefer to experiment with. The process to adding one is very similar to adding a shuffle. The file needs to be added in the `pivotSelection` folder, and provide a run function:
```
@PivotSelection("Pivot Selection Name");
new function myPivotSelection(array, start, end) -> int {
	# [start, end) is the interval in which the selection should pick a pivot
	# the code should return the index of the selected pivot
    # your code here
}
```
## Adding new rotation algorithms 
The process to adding a rotation algorithm is very similar to shuffles and pivot selections. The file needs to be added in the `rotations` folder and provide a run function:
```
# using RotationMode.INDEXED (which is default, it doesn't need to be passed)
# creates the indexed variant of the function. The Rotation class will automatically
# generate the lengths function
@Rotation("Rotation Name", RotationMode.INDEXED);
new function myRotation(array, start, middle, end) {
	# your code here
}
```
or
```
# using RotationMode.LENGTHS creates the lengths variant of the function. 
# The Rotation class will automatically generate the indexed function
@Rotation("Rotation Name", RotationMode.LENGTHS);
new function myRotation(array, start, lenA, lenB) {
	# your code here
}
```
## Adding new distributions
Adding distributions is similar to adding shuffles and pivot selections. Files need to be added to the `distributions` folder. Creating arrays doesn't use the `Value` API, since the `Value`s aren't placed in the array at that time yet.
```
@Distribution("Distribution Name");
new function myDistribution(array, length) {
    # your code here
}
```
## Working with threads
The visualizer usually operates in a sequential manner, so, to properly visualize parallel sorts, it's sufficient to call the algorithm's main function in `sortingVisualizer.runParallel(fn: Callable, *args, **kwargs)`, so that the visualizer can create a separate sort thread and run the visualization code on the main thread (since pygame has to run on the main thread), as well as properly handle highlighting. To create a thread inside of such an algorithm, `sortingVisualizer.createThread(fn: Callable, *args, **kwargs)` should be used to avoid program freezing and crashing.

## Adding visual styles
To add a visual style, a class needs to be created and inherit from the `Visual` class. That way, visuals are automatically added. Said file needs to be added in the `visuals` folder. Example:
```
new class MyVisual: Visual {
	new method __init__() {
		super.__init__(
			"Visual Name",
			highlightColor,
			refreshMode,
			outOfText
		);
	}
}
```
- `highlightColor`: a tuple containing 3 values (0, 255) in the RGB format. By default, it's set to (255, 0, 0);
- `refreshMode`: can either be `RefreshMode.LINES` for line-like visuals that intersect with the text or `RefreshMode.NOREFRESH` for visuals that don't need forced indices reloading. By default, it's set to `RefreshMode.NOREFRESH`. Note that this is only relevant for visuals that implement `selectiveDraw`;
- `outOfText`: a boolean that indicates whether the visual draws over text. If it doesn't (True), the visualizer will draw a black rectangle under the text, to refresh it. By default, it's set to `False`. This also only relevant for visuals that implement `selectiveDraw`.

The `Visual` class contains two abstract methods: 
- `draw(array: list[Value], indices: dict[int, Optional[tuple[int, int, int]]])`: draws the main array. `indices` contains the list of highlighted indices, each mapped to a color. If the mapped color is `None` the visual should draw those indices like they're not highlighted;
- `drawAux(array: list[Value], indices: dict[int, Optional[tuple[int, int, int]]])`: like `draw`, but draws the aux array.

The class also provides seven methods that get called in specific scenarios and can be overridden. By default, they do nothing:
- `init()`: gets called when the graphic system is re-initialized (usually when the resolution is changed). Useful to change data that relies on the resolution.
- `prepare()`: precomputes data for the visual style;
- `onAuxOn(length)`: gets called when aux is turned on or constants are to recompute. Useful to prepare data;
- `onAuxOff()`: gets called when aux mode is turned off. Useful to restore old values.
- `fastDraw(array: list[Value], indices: dict[int, Optional[tuple[int, int, int]]])`: like `draw`, but it can contain a lower quality version of the visual style which is less expensive to compute. By default, it just calls `draw`.
- `fastDrawAux(array: list[Value], indices: dict[int, Optional[tuple[int, int, int]]])`: like `fastDraw`, but draws the aux array. By default, it just calls `drawAux`.
- `selectiveDraw(array: list[Value], indices: dict[int, Optional[tuple[int, int, int]]])`: like `draw`, but it assumes only the highlighted indices are changed, working in a selective manner.

The `graphicsUtils.opal` file contains some presets for common visual styles.
## Adding sound systems
To add a sound system, a class needs to be created and inherit from the `Sound` class. The file needs to be added in the `sounds` folder. Example:
```
new class MySound: Sound {
	new method __init__() {
		super.__init__("Sound name");
	}
}
```
The `Sound` class contains an abstract method:
- `play(value: int | float, max_: int | float, sample: numpy.array) -> numpy.array`: generates the sound sample to be played based on the array value. The original sample should be left untouched.

The class also provides a method:
- `prepare()`: it gets called when the visualizer has to prepare the sound system. Usually used to request or load settings if it needs any, or precompute data. By default, it does nothing.
