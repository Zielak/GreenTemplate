
package components;

import luxe.Log.*;

import luxe.Input;
import luxe.Text;
import luxe.Text.TextAlign;
import luxe.tilemaps.Tilemap;
import luxe.Rectangle;
import luxe.collision.Collision;
import luxe.collision.data.ShapeCollision;
import luxe.collision.shapes.Circle;
import luxe.collision.ShapeDrawerLuxe;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.Color;
import luxe.Entity;
import luxe.Vector;
import luxe.importers.tiled.TiledTile;
import luxe.options.ComponentOptions;

using utils.VectorUtil;

class Collider extends Component
{

// Public Static stuff

    
    public static var drawer:ShapeDrawerLuxe;

    public static function init_drawer()
    {

        if(Collider.drawer == null){
            Collider.drawer = new ShapeDrawerLuxe({
                depth: 9000,
                // immediate: true,
            });
        }

    }


// Public API


    // Collision AABB box
    public var aabb:Rectangle;

    // Should your cillider be centered or something?
    public var offset:Vector;


    // AABB shortcuts for the Spatial Hash
    public var aabb_min(get, null):Vector;
    function get_aabb_min():Vector{
        return new Vector(aabb.x, aabb.y);
    }

    public var aabb_max(get, null):Vector;
    function get_aabb_max():Vector
    {
        return new Vector(aabb.x+aabb.w, aabb.y+aabb.h);
    }

    // Quick access to actor's velocity
    public var velocity(get, null):Vector;
    function get_velocity():Vector
    {
        return actor.velocity;
    }


// Internal stuff

#if debug
    var text:Text;
#end


    var _normal:Vector;
    var _collisiontime:Float; 

    var _remainingtime:Float;

    var _colliders_tested:Array<Collider>;
    var _response_vectors:Array<Vector>;


    var show_text:Bool = false;
    var show_aabb:Bool = false;




    override public function new( options:ColliderOptions )
    {
        assertnull(options, 'Collider requires at least aabb');

        super(options);


        

        aabb = options.aabb;

        offset = def(options.offset, new Vector(0,0));
        responseMap = def(options.responseMap, new Map<String, CollisionResponse>());

        gridIndex = new Array<Int>();


        touching = new Direction();
    }

    override function init():Void
    {

    } // init

    override function onadded()
    {
        super.onadded();

        _normal     = new Vector(0,0);

        updateAABB();

        text = new Text({
            parent: actor,
            pos: new Vector(aabb.w/2 + offset.x,aabb.h + offset.y),
            size: new Vector(aabb.w, aabb.h),
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            point_size: 4,
            text: actor.name.substring(actor.name.lastIndexOf('.')+1, actor.name.length),
            color: new Color(1,0.1,0.4),
            depth: actor.depth+10,
        });


        Level.current_level.grid.addBody(this);
    }

    override function onremoved()
    {
        Level.current_level.grid.removeBody(this);

        text.destroy();

        _normal     = null;

        super.onremoved();
    }

    override function update( dt:Float )
    {
#if debug
        if(actor.velocity.length > 0){
            Collider.drawer.drawLine( actor.realPos, Vector.Add( Vector.Multiply(actor.velocity, 0.5) , actor.realPos) );
        }

        if( Luxe.camera.view.viewport.point_inside( new Vector(aabb.x, aabb.y) ) ){
        // if( actor.visible ){
            if( show_aabb ){
                Collider.drawer.drawShape( luxe.collision.shapes.Polygon.rectangle(aabb.x, aabb.y, aabb.w, aabb.h, false) );
            }
            if( show_text ){
                text.visible = true;
                text.depth = actor.depth+10;
            }else if( !show_text && text.visible){
                text.visible = false;
            }
        }else{
            text.visible = false;
        }
#end
    }

    override function step( dt:Float )
    {
        var collided_with:Int = 0;

        _collisiontime = 1;
        _remainingtime = 0;
        _normal.set_xy(0,0);

        Level.current_level.grid.updateBody(this);

        touching.reset();
        updateAABB();

        // Collision tests only when moving
        if(actor.velocity.get_length2D() > 0)
        {
            _colliders_tested = new Array<Collider>();
            _colliders_tested.push(this);

            _response_vectors = new Array<Vector>();

            for( idx in gridIndex )
            {
                var _grid_cell = Level.current_level.grid.get(idx);
                // trace('##########################');
                // trace('- GID: ${idx}, has ${_grid_cell.length} colliders');

                for( two in _grid_cell )
                {
                    if( _colliders_tested.indexOf(two) >= 0 ) continue;

                    if ( AABBCheck(get_swept_broadphase(this), two.aabb) )
                    {
                        var _ct = SweptAABB(this, two, _normal, dt);
                        if( _ct >= 0 && _ct < 1 )
                        {
                            _collisiontime = _ct;
                            gather_response(this, two);
                            trace('- - closer hit with ${two.actor.name} in ${_collisiontime}, remaining: ${_remainingtime}');
                            collided_with ++;
                        }
                    }

                    // Remember that we already tested this one
                    _colliders_tested.push(two);
                }
            }


            // RESPONSE! update velocity only after checking every possible collider
            if(collided_with > 0)
            {
                respond(dt);
            }

            // trace('- Tested: ${_colliders_tested.length} / Hit: ${collided_with}');

        }

        // drawer.drawShape(shape , new Color().rgb(0x990000), true);
    }

    function gather_response(one:Collider, two:Collider, ?dt:Float)
    {
        var nVect:Vector = new Vector(velocity.x, velocity.y);

        _remainingtime = 1 - _collisiontime;

        // nVect.set_length2D( nVect.get_length2D()*_remainingtime );

        // slide
        var dotprod:Float = (nVect.x * _normal.y + nVect.y * _normal.x) * _remainingtime;
        nVect.x = dotprod * _normal.y;
        nVect.y = dotprod * _normal.x;

        _response_vectors.push(nVect);

        Collider.drawer.drawLine( two.actor.realPos, Vector.Add( Vector.Multiply(nVect, 5) , two.actor.realPos) );

        // velocity.x = nVect.x;
        // velocity.y = nVect.y;
    }

    function respond(dt)
    {
        var final:Vector = new Vector(0,0);

        for(_v in _response_vectors){
            final.x = ( Math.abs(_v.x) > final.x ) ? _v.x : final.x;
            final.y = ( Math.abs(_v.y) > final.y ) ? _v.y : final.y;
        }

        trace('- - Final response X:${final.x}, Y:${final.y}');

        actor.velocity.x = final.x;
        actor.velocity.y = final.y;

        actor.moveRealPos(dt);

        actor.cleanVectors();
    }

    function updateAABB()
    {
        aabb.x = actor.realPos.x + offset.x;
        aabb.y = actor.realPos.y + offset.y;
    }

    /**
     * SweptAABB
     * @param two       the other collider
     * @param normal    response vector, changed
     * @param dt        delta plz
     */
    function SweptAABB(one:Collider, two:Collider, normal:Vector, dt:Float):Float
    {
        var xInvEntry:Float, yInvEntry:Float;
        var xInvExit:Float, yInvExit:Float;
        var yDiff:Float = Math.NaN;
        var xDiff:Float = Math.NaN;

            // find the distance between the objects on the near and far sides for both x and y
        if (one.velocity.x > 0)
        {
            xInvEntry = two.aabb.x - (one.aabb.x + one.aabb.w);
            xInvExit = (two.aabb.x + two.aabb.w) - one.aabb.x;
        }
        else if (one.velocity.x < 0)
        {
            xInvEntry = (two.aabb.x + two.aabb.w) - one.aabb.x;
            xInvExit = two.aabb.x - (one.aabb.x + one.aabb.w);
        }
        else
        {
            xInvEntry = Math.NaN; 
            xInvExit = Math.NaN;

            // going straight in y axis, no X Velocity.
            if ( one.aabb.x + one.aabb.w <= two.aabb.x ){
                // Am I to the left?
                xDiff = two.aabb.x - (one.aabb.x + one.aabb.w);
            }else if ( one.aabb.x >= two.aabb.x + two.aabb.w ){
                // Am I to the right?
                xDiff = one.aabb.x - (two.aabb.x + two.aabb.w);
            }
        }

        if (one.velocity.y > 0)
        {
            yInvEntry = two.aabb.y - (one.aabb.y + one.aabb.h);
            yInvExit = (two.aabb.y + two.aabb.h) - one.aabb.y;
        }
        else if (one.velocity.y < 0)
        {
            yInvEntry = (two.aabb.y + two.aabb.h) - one.aabb.y;
            yInvExit = two.aabb.y - (one.aabb.y + one.aabb.h);
        }
        else
        {
            yInvEntry = Math.NaN;
            yInvExit = Math.NaN;

            // going straight in x axis, no Y Velocity.
            if ( one.aabb.y + one.aabb.h <= two.aabb.y ){
                // Am I above the two?
                yDiff = two.aabb.y - (one.aabb.y + one.aabb.h);
            }else if ( one.aabb.y >= two.aabb.y + two.aabb.h ){
                // Am I below the two?
                yDiff = one.aabb.y - (two.aabb.y + two.aabb.h);
            }
        }

        // find time of collision and time of leaving for each axis (if statement is to prevent divide by zero)
        var xEntry:Float, yEntry:Float;
        var xExit:Float, yExit:Float;

        if (one.velocity.x == 0 || (one.velocity.x != 0 && yDiff >= 0) )
        {
            xEntry = Math.NEGATIVE_INFINITY;
            xExit = Math.POSITIVE_INFINITY;
        }
        else
        {
            xEntry = xInvEntry / (one.velocity.x*dt);
            xExit = xInvExit / (one.velocity.x*dt);
        }

        if (one.velocity.y == 0 || (one.velocity.y != 0 && xDiff >= 0))
        {
            yEntry = Math.NEGATIVE_INFINITY;
            yExit = Math.POSITIVE_INFINITY;
        }
        else
        {
            yEntry = yInvEntry / (one.velocity.y*dt);
            yExit = yInvExit / (one.velocity.y*dt);
        }

        // find the earliest/latest times of collision
        var entryTime:Float = Math.max(xEntry, yEntry);
        var exitTime:Float = Math.min(xExit, yExit);

        // trace('entryTime: ${entryTime}');

        // if there was no collision
        if (entryTime > exitTime || xEntry < 0 && yEntry < 0 || xEntry > 1 || yEntry > 1)
        {
            // normal.x = 0;
            // normal.y = 0;
            return 1;
        }
        else // if there was a collision
        {
            // trace('entryTime: ${entryTime}');
            // calculate normal of collided surface
            if (xEntry > yEntry)
            {
                if (xInvEntry < 0)
                {
                    normal.x = 1;
                    // normal.y = 0;
                }
                else
                {
                    normal.x = -1;
                    // normal.y = 0;
                }
            }
            else
            {
                if (yInvEntry < 0)
                {
                    // normal.x = 0;
                    normal.y = 1;
                }
                else
                {
                    // normal.x = 0;
                    normal.y = -1;
                }
            }

            // return the time of collision
            return entryTime;
        }
    } // SweptAABB

    function get_swept_broadphase(one:Collider):Rectangle
    {
        var broadphasebox:Rectangle = new Rectangle();
        broadphasebox.x = one.velocity.x > 0 ? one.aabb.x : one.aabb.x + one.velocity.x;
        broadphasebox.y = one.velocity.y > 0 ? one.aabb.y : one.aabb.y + one.velocity.y;
        broadphasebox.w = one.velocity.x > 0 ? one.velocity.x + one.aabb.w : one.aabb.w - one.velocity.x;
        broadphasebox.h = one.velocity.y > 0 ? one.velocity.y + one.aabb.h : one.aabb.h - one.velocity.y;

        return broadphasebox;
    } // get_swept_broadphase

    function AABBCheck(one:Rectangle, two:Rectangle):Bool
    {
        return !(one.x + one.w < two.x || one.x > two.x + two.w || one.y + one.h < two.y || one.y > two.y + two.h);
    } // AABBCheck

    override function onkeydown(e:KeyEvent)
    {
        if(e.keycode == Key.key_o){
            show_text = !show_text;
        }
        if(e.keycode == Key.key_p){
            show_aabb = !show_aabb;
        }
        
    }


}

typedef ColliderOptions = {
    > ComponentOptions,

    var aabb:Rectangle;
    @:optional var offset:Vector;
    @:optional var responseMap:Map<String, CollisionResponse>;
}

typedef ColliderEvent = {

    var touching:Direction;
    @:optional var tileX:Tile;
    @:optional var tileY:Tile;
}

enum CollisionResponse {
    Ignore;     // Don't collide, pass through
    Stay;       // Stay, stick, don't use out remaining time
    Deflect;    // Bounce
    Push;       // Go all the time, way down
    Slide;      // Match destination max
}
