![logo](https://user-images.githubusercontent.com/97792861/163704911-580f807c-71a2-42e9-8c54-32e7027a15c1.png)




# Theoyeah Engine

Hello, here a (again) new edited version psych engine !
I will try to add things that shadow mario will never do



# What it adds 

- Noteskin Option (by phonetech97)
- New Logo
- New Icon
- Winning Icons (from Mic up' Engine)
- new funkay.png
- Fucked difficulty 
- longer health bar
- tweaked scoretxt 
- opponent take health when pressing note
- opponent noteplashes ! (by frantastic24)
- Better Menu !
- no more donate button (look at readme.txt if you want to donate at original creator of fnf)
- added flash when selecting something
- red flash when you die
- added marvelous
- Kade Score text option !
- More soon !
- insta-kill note
- funni 9 button easter egg icon
- Shaders are real
- Os is back !!!
- Added a cool background in intro
- Added the original MiddleScroll !
# Examples :
![image](https://user-images.githubusercontent.com/97792861/163772539-3409759d-5fca-4a5a-945f-76f4b7ed87fb.png)
![image](https://user-images.githubusercontent.com/97792861/163772686-7020ae13-c6ab-48a7-bdcc-6ee2c6d4eb7f.png)
![image](https://user-images.githubusercontent.com/97792861/163772872-878c2361-1971-4274-b6e2-27125298c35e.png)





# How to compile
You must have the most up-to-date version of Haxe, seriously, stop using 4.1.5, it misses some stuff.
Installing the Required Programs
First, you need to install Haxe and HaxeFlixel. I'm too lazy to write and keep updated with that setup (which is pretty simple).
Install HaxeFlixel after downloading Haxe
Other installations you'd need are the additional libraries, a fully updated list will be in Project.xml in the project root. Currently, these are all of the things you need to install:

- flixel
- flixel-addons
- flixel-ui
- hscript
- newgrounds

So for each of those type haxelib install [library] so shit like haxelib install newgrounds

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.

Download git-scm. Works for Windows, Mac, and Linux, just select your build.
Follow instructions to install the application properly.
Run haxelib git polymod https://github.com/larsiusprime/polymod.git to install Polymod.
Run haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc to install Discord RPC.
You should have everything ready for compiling the game! Follow the guide below to continue!

At the moment, you can optionally fix the transition bug in songs with zoomed-out cameras.

Run haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons in the terminal/command-prompt.


after this you will need to install LuaJIT.

To install LuaJIT do this: haxelib git linc_luajit https://github.com/AndreiRudenko/linc_luajit on a Command prompt/PowerShell

...Or if you don't want your mod to be able to run .lua scripts, delete the "LUA_ALLOWED" line on Project.xml

To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run lime test linux -debug and then run the executable file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:

- MSVC v142 - VS 2019 C++ x64/x86 build tools and 
- Windows SDK (10.0.17763.0)

Once that is done you can open up a command line in the project's directory and run lime test windows -debug. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.
