
import luxe.Input;
import luxe.Color;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Physics;
import luxe.Rectangle;
import luxe.Scene;
import luxe.Sprite;
import luxe.States;
import luxe.Text;
import luxe.utils.Random;
import luxe.Vector;

class Main extends luxe.Game
{

    public static var random:Random;


    //      DUDE, it's Luxe.screen.w ...
    // public static var width     (get, null):Float;
    // public static var height    (get, null):Float;

    // Everything happens in States!
    var machine:States;


    override function config(config:luxe.AppConfig)
    {

        return config;

    } //config

    override function ready()
    {

        preload_assets();

    } //ready


    override function onkeyup( e:KeyEvent )
    {

        if(e.keycode == Key.escape)
        {
            Luxe.shutdown();
        }
        // if(e.keycode == Key.key_n)
        // {
        //     Main.physics.paused = !Main.physics.paused;
        // }
        // if(e.keycode == Key.key_m && Main.physics.paused)
        // {
        //     Main.physics.forceStep();
        // }


    } //onkeyup

    override function onmousemove( e:MouseEvent )
    {
        
    } // onmousemove

    override function update(dt:Float)
    {

    } //update


    /**
     * Shader stuff
     */
    override function onprerender()
    {
        // if(hud != null){
        //     if(hud.has('grayscaleshader')){
        //         hud.get('grayscaleshader').onprerender();
        //     }
        // }
    }

    override function onpostrender()
    {
        // if(hud != null){
        //     hud.hud_batcher.draw();
        //     if(hud.has('grayscaleshader')){
        //         hud.get('grayscaleshader').onpostrender();
        //     }
        // }
    }




// Internal
    
    function preload_assets()
    {
        var parcel = new Parcel({
            textures : [
                { id:'assets/dg_logo.gif' },
            ]
        });

        new ParcelProgress({
            parcel      : parcel,
            background  : new Color(0,0,0,0.85),
            oncomplete  : assets_loaded,
        });

            //go!
        parcel.load();

    } // preload_assets


    function init_states()
    {
        // Machines
        machine = new States({ name:'statemachine' });

        machine.add( new Game({
            // what: true
        }) );
        
        machine.set('game');
        
    }



    function assets_loaded(_)
    {

        Luxe.renderer.clear_color = new Color().rgb(0x000000);


        init_states();

        Luxe.events.fire('game.assets.loaded');

    } // assets_loaded


} //Main
