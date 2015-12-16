
import luxe.Component;

class Component extends luxe.Component
{

    public var actor(get, null):Actor;
    public function get_actor():Actor
    {
        return actor;
    }

    public function step(dt:Float) {}

    override function onadded():Void
    {
        
        actor = cast entity;

    } // onadded


    override function onremoved():Void
    {

        actor = null;

    } // onremoved

}
