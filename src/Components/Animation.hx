
package components;

import components.Mover;
import components.SpriteAnimation;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;
import luxe.options.ComponentOptions;

using utils.VectorUtil;

class Animation extends Component{

    public var anim:SpriteAnimation;
    var options:AnimationOptions;

    override public function new( _options:AnimationOptions )
    {
        options = _options;
    }

    override function init()
    {
        anim = new SpriteAnimation({name: 'anim'});
        actor.add(anim);

        anim.add_from_json(options.json);
        anim.animation = options.start_animation;
        anim.play();

        init_events();

    }

    // Override to setup events after animations are done
    public function init_events() {}

    

        
} // Animation

typedef AnimationOptions = {
    > ComponentOptions,

    var json:String;
    var start_animation:String;
}
