package components;

import luxe.collision.data.ShapeCollision;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.Component;
import luxe.Entity;
import luxe.options.ComponentOptions;
import luxe.Sprite;
import luxe.Vector;

class Collider extends Component {

    @:isVar public var shape (default, null):Shape;


    public var enabled:Bool = true;

    var offset:Vector;

    var testAgainst:Array<String>;

    var _entities:Array<Entity>;
    var collision:ShapeCollision;

    override public function new(options:ColliderOptions)
    {


        options.name = 'collider';

        if(options.testAgainst != null){
            testAgainst = options.testAgainst;
        }

        if(options.offset != null){
            offset = options.offset;
        }else{
            offset = new Vector(0,0);
        }

        shape = options.shape;

        super(options);

    }

    override function init()
    {
        entity.fixed_rate = 1/60;
        _entities = new Array<Entity>();


        Luxe.events.listen('game.over.*', function(_){
            enabled = false;
        });
    }

    override function onadded()
    {

    }

    override function ondestroy()
    {
        shape = null;
        testAgainst = null;
        _entities = null;
        collision = null;
    }




    override function onfixedupdate(rate:Float)
    {

        shape.x = entity.pos.x + offset.x;
        shape.y = entity.pos.y + offset.y;

        if(testAgainst != null && enabled)
        {
            for(n in testAgainst)
            {
                test_collision(n);
            }
        }
        
        // Game.shape_drawer.drawShape(shape);
    }

    override function update(dt:Float)
    {
        
    }

    function test_collision( test_name:String )
    {

        var _collider:Collider;

        _entities = new Array<Entity>();

        _entities = Luxe.scene.get_named_like( test_name, _entities );

        for(_entity in _entities)
        {
            if(this.entity.destroyed){
                // already destroyed, dummie...
                break;
            }

            if(_entity.has('collider'))
            {
                _collider = cast (_entity.get('collider'), Collider);
                if(_collider != null)
                {
                    // Other must be enabled
                    if(!_collider.enabled) continue;

                    // TEST
                    collision = shape.test( _collider.shape );
                    
                    if(collision == null) continue;

                    trace('got hit!');
                    
                    _entity.events.fire('collider.hit', {
                        coldata: collision,
                        other: entity,
                    });

                    entity.events.fire('collider.hit', {
                        coldata: collision,
                        other: _entity,
                    });
                }
            }
        }
    }

}



typedef ColliderOptions = {
    > ComponentOptions,

    var shape:Shape;
    @:optional var offset:Vector;
    @:optional var testAgainst:Array<String>;
}

typedef ColliderEvent = {
    var coldata:ShapeCollision;
    var other:Entity;
}
