# PlutoniumIW5 Bot Warfare Waypoint Editor
First things first, Bot Warfare uses the [AStar search algorithm](https://en.wikipedia.org/wiki/A*_search_algorithm) for creating paths for the bots to find their way through a map. 

The AStar search algorithm requires a [set of waypoints](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)) defining where all the paths are in the map.

Now if you want to modify existing or create new waypoints for PlutoniumIW5 maps, this is the read for you.

## Contents
- [Setting up the Waypoint Editor](#Setting-up-the-Waypoint-Editor)
- [The Editor](#The-Editor)

## Setting up the Waypoint Editor
The Bot Warfare mod comes with the Waypoint Editor out of the box, so its just a matter of telling the mod you want to use it. Its a matter of setting the 'bots_main_debug' DVAR to '1'.

Start your game, and load up the Bot Warfare mod. Now open your console with tilde(~).<br>
![How tilde](/raw/bw-assets/how-tilde.png)

In the console, type in ```set bots_main_debug 1```<br>
![Setting the dvar](/raw/bw-assets/wp-editor-debug-dvar.png)

Now start a match with the map you want to edit.

## The Editor
![The editor](/raw/bw-assets/wp-editor-0.png)<br>
This is the Waypoint Editor. You can view, edit and create the waypoint graph.
- Each death icons you see are waypoints.
- Each line of knives show the links between the waypoints, a link defines that a bot can walk from A to B.

---

Pressing any of these buttons will initiate a command to the Waypoint Editor.

- SecondaryOffhand (stun) - Add Waypoint
  - No modifier button - Make a waypoint of your stance
  - ADS, climbing or mounting - Make a climb waypoint
  - Attack + Use - Make a noobtube waypoint
  - Attack - Make a grenade waypoint
  - Use - Make a claymore waypoint
  - Marking a location with the Javelin - Make a Javelin waypoint

- Melee - Link waypoint

- Reload - Unlink waypoint

- PrimaryOffhand (frag) - Toggle autolink waypoints (links waypoints as you create them)

- ActionSlot3 (switch to alt weapon mode (noobtube)) - Delete Waypoint

- ActionSlot4 (killstreak activate) - Delete all waypoints

- ActionSlot1 (Nightvision) - Save Waypoints

- ActionSlot2 (killstreak activate first slot) - (Re)Load Waypoints

- Use - Display the nearest waypoint's list of linked waypoints.

---

Okay, now that you know how to control the Editor, lets now goahead and create some waypoints.

Here I added a waypoint.<br>
![Adding a waypoint](/raw/bw-assets/wp-editor-added.png)

And I added a second waypoint.<br>
![Adding another waypoint](/raw/bw-assets/wp-editor-added2.png)

There are several types of waypoints, holding a modifier button before pressing the add waypoint button will create a special type of waypoint.
- Types of waypoints:
  - any stance ('stand', 'crouch', 'prone') - bots will have this stance upon reaching this waypoint
  - grenade - bots will look at the angles you were looking at when you made the waypoint and throw a grenade from the waypoint
  - tube - bots will look at the angles you were looking at when you made the waypoint and switch to a launcher and fire
  - claymore - bots will look at the angles you were looking at when you made the waypoint and place a claymore or tactical insertion
  - camp ('crouch' waypoint with only one linked waypoint) - bots will look at the angles you were looking at when you made the waypoint and camp
  - climb - bots will look at the angles you were looking at when you made the waypoint and climb (use this for ladders and mantles)
  - javelin - bots will use the javelin and lockon at the target location

Here I linked the two waypoints together.<br>
![Linking waypoints](/raw/bw-assets/wp-editor-linked.png)

Linking waypoints are very important, it tells the bots that they can reach waypoint 1 from waypoint 0, and vice versa.

Now go and waypoint the whole map out. This may take awhile and can be pretty tedious.

Once you feel like you are done, press the Save button. This will output the waypoints to your `games_mp.log` file.

Your `games_mp.log` can be located at the `C:\Users\<LOGINNAME>\AppData\Plutonium\storage\iw5` folder.<br>
![games_mp.log location](/raw/bw-assets/wp-editor-gamesmp_loc.png)


The editor will generate some GSC code for the waypoints.<br>
![games_mp.log](/raw/bw-assets/wp-editor-gamesmp.png)<br>
This is the GSC function that will generate the waypoints for the map. If you have trouble beyond this point, simply create an Issue and provide the output from here, I can do the rest from there.

You can create/replace the map's waypoints GSC file with the function in `games_mp.log`.  
Just copy and paste the function into the `scripts\mp\<MAPNAME>\<WAYPOINT>.gsc` file.  
If you're working with a custom map you might need to create the folder with your map's name.  
Then inside that newly created folder put your waypoints GSC file.  
Make sure to have it named `wps_mapname`.  
Also you need to add this `main` function at the topc of your waypoints GSC file to ensure Bot Warfare will load your waypoints. Replace `Dome` with the name of the function in your file.
```
main()
{
    level.waypoints = Dome();
}
```
<br>

![GSC waypoints path](/raw/bw-assets/wp-editor-wps-path.png)
![GSC waypoints](/raw/bw-assets/wp-editor-wps.png)


Now Bot Warfare will use your waypoints you've created!  
Create a pull request to have your waypoints included in the mod if you like, any help is greatly appreciated.
