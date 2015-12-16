
package ;

import luxe.Visual;
import luxe.Color;
import luxe.Vector;

using utils.VectorUtil;

class Actor extends Visual
{


        // Direction-aware velocity
    public var velocity         :Vector;

        // constant addition
    public var acceleration     :Vector;

        // Force is reset back to zero on each frame.
        // Should be used to apply impulse forces, like jump.
    public var force            :Vector;

        // gets data from/to velocity
    public var speed(get, set)  :Float;

        // Real position of Actor, right before it's rounded for view
    public var realPos          :Vector;

        // Is this actor on ground?
    public var on_ground(get, null):Bool;




    override public function new( _options:luxe.options.VisualOptions #if debug, ?_pos_info:haxe.PosInfos #end )
    {

        super(_options);

        velocity        = new Vector();
        acceleration    = new Vector();
        force           = new Vector();

        realPos = new Vector();
        realPos.copy_from(pos);
    }

    override function init():Void
    {
        
    }

    override function ondestroy():Void
    {
        realPos = null;
    }

    override function update(dt:Float):Void
    {
        pos.copy_from(realPos);

        pos.x = Math.round(pos.x);
        pos.y = Math.round(pos.y);
        pos.z = Math.round(pos.z);
    }

// Public

    public function applyForce(_x:Float, _y:Float, ?_z:Float = 0):Void
    {
        force.x += _x;
        force.y += _y;
        force.z += _z;
    } // applyForce

    // Clean vectors
    public function cleanVectors()
    {
        if( Math.abs(velocity.x) < 0.01 && velocity.x != 0 ) velocity.x = 0;
        if( Math.abs(velocity.y) < 0.01 && velocity.y != 0 ) velocity.y = 0;
        if( Math.abs(velocity.z) < 0.01 && velocity.z != 0 ) velocity.z = 0;
    }

    // Immediately update real position.
    // Helpful when 
    public function moveRealPos(dt:Float)
    {
        cleanVectors();

        realPos.x += velocity.x * dt;
        realPos.y += velocity.y * dt;
        realPos.z += velocity.z * dt;
    }

    public function step(dt:Float)
    {

        velocity.add(force);
        velocity.add(acceleration);

        moveRealPos(dt);

        force.set_xyz(0,0,0);
        // acceleration.copy_from(Main.physics.gravity);

        this.depth = realPos.y/100;
    }




// Public Getters/Setters
    
    public function get_speed():Float
    {
        return velocity.get_length2D();
    }

    public function set_speed(v:Float):Float
    {
        velocity.set_length2D(v);
        return velocity.get_length2D();
    }

    // Override to define your own thing
    public function get_on_ground():Bool
    {
        return false;
    }




// Internal functions



}
