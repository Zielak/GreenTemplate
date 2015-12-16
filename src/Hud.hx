
package ;

import luxe.options.EntityOptions;
import luxe.Entity;
import luxe.Input;
import luxe.Rectangle;
import luxe.Text;
import luxe.utils.Maths;
import luxe.Vector;
import luxe.Color;
import luxe.Visual;

import phoenix.Batcher;
import phoenix.Camera;




class Hud extends Entity
{

    @:isVar public var hud_batcher(default, null):Batcher;


    /**
     * What actor to follow?
     */
    public var followTarget:Actor;

    /**
     * Maximum deadzone for the followed actor
     */
    var deadzone:Rectangle;
    public var max_distance:Float;

    /**
     * Camera position, before rounding
     */
    var camPos:Vector;

    /**
     * Lerp for camera movement
     */
    var followLerp:Float = 1;    // 0.07

    /**
     * Temp vafiable for getting difference
     */
    var diff:Vector;

    /**
     * Cursor
     */
    // var cursor:Cursor;

    // Key input, camera modes debug
    // HOLD C and then hit 1-0
    var _debugHeld:Bool = false;
    var _mode:Int = 1;

    
    override public function init():Void
    {
        hud_batcher = Luxe.renderer.create_batcher({
            name : 'hud_batcher',
            layer : 10,
            no_add : true,
        });

        setup_camera();
        setup_hud();
        setup_cursor();

        init_events();
    }

    function init_events()
    {

    }

    function setup_camera()
    {
        Luxe.camera.size = new Vector( Luxe.screen.w, Luxe.screen.h );
        Luxe.camera.zoom = 4;

        Luxe.camera.pos.x = roundPixels(Luxe.camera.pos.x);
        Luxe.camera.pos.y = roundPixels(Luxe.camera.pos.y);

        camPos = new Vector(Luxe.camera.center.x, Luxe.camera.center.y);

        deadzone = new Rectangle();
    }

    function setup_hud()
    {

        // var textField = new Text({
        //     pos : new Vector(5,Luxe.screen.h/3),
        //     point_size : 16,
        //     depth : 3.5,
        //     align : TextAlign.left,
        //     text : '',
        //     color : new Color().rgb(0xFFFFFF),
        //     batcher : hud_batcher
        // });

    }


    function setup_cursor()
    {
        // cursor = new Cursor({batcher: hud_batcher});
        // add(cursor);
    }


    override function update(dt:Float)
    {

        if( followTarget != null )
        {

            if (followLerp >= 1)
            {
                Luxe.camera.center.x = roundPixels(followTarget.pos.x);
                Luxe.camera.center.y = roundPixels(followTarget.pos.y);
            }
            else
            {
                var helper:Float = Luxe.camera.size.x / 64;
                deadzone.set(
                    // (Luxe.screen.w / Luxe.camera.zoom - helper) / 2,
                    // (Luxe.screen.h / Luxe.camera.zoom - helper) / 2,
                    -helper/2,
                    -helper/2,
                    helper,
                    helper
                );

                camPos.x = Maths.lerp(camPos.x, followTarget.pos.x, followLerp);
                camPos.y = Maths.lerp(camPos.y, followTarget.pos.y, followLerp);

                var edge:Float;
                var targetX:Float = followTarget.pos.x;
                var targetY:Float = followTarget.pos.y;


                edge = targetX - deadzone.x;
                if (camPos.x > edge)
                {
                    camPos.x = edge;
                } 
                edge = targetX - deadzone.x - deadzone.w;
                if (camPos.x < edge)
                {
                    camPos.x = edge;
                }
                
                edge = targetY - deadzone.y;
                if (camPos.y > edge)
                {
                    camPos.y = edge;
                }
                edge = targetY - deadzone.y - deadzone.h;
                if (camPos.y < edge)
                {
                    camPos.y = edge;
                }

                Luxe.camera.center.x = roundPixels( camPos.x );
                Luxe.camera.center.y = roundPixels( camPos.y );

            }

        }
        
    }


    // override function onkeydown(e:KeyEvent):Void
    // {
    //     if(e.keycode == Key.key_c)
    //     {
    //         _debugHeld = true;
    //     }

    //     if(_debugHeld)
    //     {
    //         if(e.keycode >= 49 && e.keycode <= 57)
    //         {
    //             _mode = e.keycode - 48;
    //         }
    //     }
    // }

    // override function onkeyup(e:KeyEvent):Void
    // {
    //     if(e.keycode == Key.key_c)
    //     {
    //         _debugHeld = false;
    //     }
    // }

    public static function roundPixels(val:Float):Float
    {
        return Math.round( val*Luxe.camera.zoom ) / Luxe.camera.zoom;
        // return Math.round( val );
    }

    public static function floorToMatchPixels(val:Float):Float
    {
        return Math.floor( val*Luxe.camera.zoom ) / Luxe.camera.zoom;
    }





}
