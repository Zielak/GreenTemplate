
import luxe.Entity;
import luxe.Input;
import luxe.Color;
import luxe.Rectangle;
import luxe.Scene;
import luxe.Sprite;
import luxe.States;
import luxe.Log.*;
import luxe.collision.ShapeDrawerLuxe;
import luxe.tween.Actuate;
import luxe.utils.Maths;
import luxe.utils.Random;
import luxe.Vector;

class Game extends State {

    public static inline var width:Int = 160;
    public static inline var height:Int = 144;

    public static var random:Random;
    public static var drawer:ShapeDrawerLuxe;


    // is game on? If not, then it's probably preparing (startup stuff)
    public static var playing:Bool = false;

    // Did we just loose?
    public static var gameover:Bool = false;

    // quick delay during gameplay, like getting mushroom in Mario
    public static var delayed:Bool = false;


    // playtime?
    public static var time:Float = 0;

    public static var difficulty:Float = 0;





    




    // User interface
    var hud:Hud;

    // Hold every kind of events here.
    // Quick for kililng events when game is over.
    var game_events:Array<String>;


    public function new(options:GameOptions)
    {

        super({ name:'game' });

        Game.random = new Random(Math.random());
        // Game.scene = new Scene('gamescene');

        Game.drawer = new ShapeDrawerLuxe();

    }

    override function onleave<T>(_:T)
    {

        hud.destroy();

        kill_events();
        // Game.scene.empty();

    }

    override function onenter<T>(_:T) 
    {
        reset();

        create_hud();

        init_events();

        Luxe.timer.schedule(3, function(){
            playing = true;
            Luxe.events.fire('game.start');
        });


        Luxe.events.fire('game.init');

    }

    function reset()
    {
        Game.difficulty = 0;
        Game.time = 0;

        Game.playing = false;
        Game.gameover = false;
        Game.delayed = false;

        Game.random.reset();

        Luxe.events.fire('game.reset');
    }

    function game_over(reason:String)
    {

        Game.playing = false;
        Game.gameover = true;
        Luxe.events.fire('game.over.${reason}');

    }

    function create_hud()
    {
        hud = new Hud({
            name: 'hud',
        });
    }


    function create_player()
    {

        // player = new Player({
        //     name: 'player',
        //     name_unique: true,
        //     texture: Luxe.resources.texture('assets/images/player.gif'),
        //     size: new Vector(16,16),
        //     pos: new Vector(160/2, 144/2),
        //     centered: true,
        //     depth: 10,
        //     scene: Game.scene,
        // });
        // player.texture.filter_mag = nearest;
        // player.texture.filter_min = nearest;

    }

    function init_events()
    {
        game_events = new Array<String>();

        // Finally start the sequence when they touch
        // game_events.push( Luxe.events.listen('player.hit.gal', function(_)
        // {
        //     trace('player.hit.gal !!');
        //     Actuate.tween(Game, 2, {speed:0});
            
        //     spawner.events.fire('sequence.gal');
        // }) );
    }

    function kill_events()
    {
        for(s in game_events)
        {
            Luxe.events.unlisten(s);
        }
    }



    override function update(dt:Float)
    {

        if(Game.playing && !Game.delayed)
        {
            
            Game.time += dt;

        }

    }




    // HAXXX
    override public function onkeydown( event:KeyEvent )
    {

        if(event.keycode == Key.key_p){
            Game.delayed = !Game.delayed;
        }

    }




}


typedef GameOptions = {
    @:optional var tutorial:Bool;
}
