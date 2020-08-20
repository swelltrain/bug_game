backstory:
we are looking under a microscope at protozoans and bacteria.  we need to get rid of them and the only way to do it is with (these attacker guys) that need
to be spooked.  unfortunately if you fly out of the microscope you are lost forever.

todo:
DONE can we remove the sprites once they have been added to static_sprites?  i dont think so?  at least not easily.  this would
be useful for collisions/food etc.  so we should move anything that might be killed to args.outputs.sprites << args.state.enemies, etc

we have to figure out a way to kill the baddies
bumping them when in attack mode seems lame.  too easy to turn back right when attacking.
how about an attack dog?  instead of eating the food, we disturb the attacker.  it zooms around
bumping baddies and killing them for a few seconds.  we will stay in attack mode for that time too.

score: number of ticks?  add something for each baddie killed?

let create a bunch of tiny brownian motion particles.  they can be in static sprites and will be two or three pixels long.
maybe let them "move" out of the way when there is a collision?
