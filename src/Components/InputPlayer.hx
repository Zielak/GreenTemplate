
package components;


import luxe.Input;
import luxe.Vector;

class InputPlayer extends Component
{
    public static var MOVE_AXIS_X:Int = 0;
    public static var MOVE_AXIS_Y:Int = 1;

    @:isVar public var up       (default, null):Bool;
    @:isVar public var down     (default, null):Bool;
    @:isVar public var left     (default, null):Bool;
    @:isVar public var right    (default, null):Bool;

    @:isVar public var dir      (default, null):Int;

    @:isVar public var a        (default, null):Bool;
    @:isVar public var b        (default, null):Bool;
    @:isVar public var jump     (default, null):Bool;

    @:isVar public var angle        (default, null):Float;
    @:isVar public var movePressed  (default, null):Bool;


    @:isVar public var moveStickX   (default, null):Float;
    @:isVar public var moveStickY   (default, null):Float;


    @:isVar public var aim_angle    (default, null):Float;
    var _aim:Vector;


    var _moveStick:Vector;

    // Track mouse position
    var mouse_pos:Vector;


    override function init():Void
    {
        // trace('InputPlayer.init()');
        angle = 0;
        aim_angle = 0;

        moveStickX = 0;
        moveStickY = 0;
        _moveStick = new Vector(0,0);
        mouse_pos = new Vector(0,0);
        _aim = new Vector(0,0);

        // TODO: options and add more then one set:
        Luxe.input.bind_key('up', Key.up);
        Luxe.input.bind_key('down', Key.down);
        Luxe.input.bind_key('left', Key.left);
        Luxe.input.bind_key('right', Key.right);

        Luxe.input.bind_key('a', Key.key_c);
        Luxe.input.bind_key('b', Key.key_x);
        Luxe.input.bind_key('jump', Key.space);

        // Alt set
        Luxe.input.bind_key('up', Key.key_w);
        Luxe.input.bind_key('down', Key.key_s);
        Luxe.input.bind_key('left', Key.key_a);
        Luxe.input.bind_key('right', Key.key_d);
        
        Luxe.input.bind_key('a', Key.key_k);
        Luxe.input.bind_key('b', Key.key_l);

        // Mouse input
        Luxe.input.bind_mouse('a', MouseButton.left);
        Luxe.input.bind_mouse('b', MouseButton.right);



        //only the gamepad=1 fires this named binding when button 2 is pressed
        Luxe.input.bind_gamepad('a', 2);
        Luxe.input.bind_gamepad('b', 0);

        Luxe.input.bind_gamepad('up', 11);
        Luxe.input.bind_gamepad('down', 12);
        Luxe.input.bind_gamepad('left', 13);
        Luxe.input.bind_gamepad('right', 14);
    }

    override function oninputup( event:{ name:String, event:InputEvent } ) {
        // trace( 'named input up : ' + event.name );
    } //oninputup

    override function oninputdown( event:{ name:String, event:InputEvent } ) {
        // trace( 'named input down : ' + event.name );
    } //oninputdown

    override function ongamepadaxis( event:GamepadEvent ) {
        if(event.axis == MOVE_AXIS_X){
            moveStickX = event.value;
        }else if(event.axis == MOVE_AXIS_Y){
            moveStickY = event.value;
        }
    }

    override function onmousemove( event:MouseEvent )
    {

        mouse_pos.copy_from( event.pos );

        _aim = new Vector().copy_from(mouse_pos);
        _aim.x -= Luxe.screen.w / 2;
        _aim.y -= Luxe.screen.h / 2;

        aim_angle = _aim.angle2D;
    }
/*
    override function onmousedown( event:MouseEvent )
    {
        if( event.button == MouseButton.left ){
            a = true;
        }
        if( event.button == MouseButton.right ){
            b = true;
        }
    }
    override function onmouseup( event:MouseEvent )
    {
        if( event.button == MouseButton.left ){
            a = false;
        }
        if( event.button == MouseButton.right ){
            b = false;
        }
    }
*/

    // TODO: update key bindings, from outside ( global config?)

    override function update(dt:Float):Void
    {
        updateKeys();

        Luxe.events.fire('input.gamepad.moveStick', {x:moveStickX, y:moveStickY} );

        // Luxe.input.gamepadaxis(0, 0);
    }


    function updateKeys():Void
    {
        up    = Luxe.input.inputdown('up');
        down  = Luxe.input.inputdown('down');
        left  = Luxe.input.inputdown('left');
        right = Luxe.input.inputdown('right');

        a     = Luxe.input.inputdown('a');
        b     = Luxe.input.inputdown('b');
        jump  = Luxe.input.inputpressed('jump');

        _moveStick.x = moveStickX;
        _moveStick.y = moveStickY;



        // Should the whole thing be in here or in PlayerMovement?
        if( up && down )
        {
            up = down = false;
        }
        if( left && right )
        {
            left = right = false;
        }


        movePressed = false;


        if( _moveStick.length < 0.15 && (up || down || left || right) )
        {
            movePressed = true;

            if ( up )
            {
                angle = Math.PI*3 / 2;//-90;
                if ( left)
                    angle -= Math.PI/4;
                else if ( right)
                    angle += Math.PI/4;
            }
            else if ( down )
            {
                angle = Math.PI/2;//90;
                if ( left )
                    angle += Math.PI/4;
                else if ( right )
                    angle -= Math.PI/4;
            }
            else if ( left )
                angle = Math.PI;
            else if ( right )
                angle = 0;
        }
        else if( _moveStick.length >= 0.15 )
        {
            movePressed = true;

            angle = Direction.angle2angle8( _moveStick.angle2D );
        }

        
    }

}

typedef MoveStick = {
    var x:Float;
    var y:Float;
}
