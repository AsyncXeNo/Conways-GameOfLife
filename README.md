# Description
*This is my implementation of Conway's Game of Life, made using lua and LÖVE 2D.*

**The rules are simple.**
**There is a grid of cells, which are either alive or dead.**
**After a step of time:**
- **Alive cells with exactly two or three alive neighbors live on.**
- **Dead cells with exactly three alive neighbors become alive.**
- **All other cells die or remain dead.**

# Controls

| Key                | Action                                                              |
|--------------------|---------------------------------------------------------------------|
| **Left Click**     | Make Cell Alive                                                     |
| **Right Click**    | Make Cell Dead                                                      |
| **Space**          | One Step Forward in Time                                            |
| **P**              | Keep Stepping Forward in Time automatically / Stop Stepping Forward |
| **+**              | Increase Speed                                                      |
| **-**              | Decrease Speed                                                      |
| **w**              | Scroll Up                                                           |
| **a**              | Scroll Left                                                         |
| **s**              | Scroll Down                                                         |
| **d**              | Scroll Right                                                        |
| **Click and Drag** | Scroll while in Play Mode                                           |
| **Escape**         | Quit                                                                |

# Requirements
- **Lua**
- **LÖVE 2D**

# Running the game
You can find an **exe** file in the releases.
Alternatively, download the **GOL.love** file and run it using love.
