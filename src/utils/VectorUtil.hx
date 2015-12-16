
package utils;

import luxe.Vector;

class VectorUtil
{

    public static function x_int( v:Vector ):Int
    {
        return Math.floor(v.x);
    }

    public static function y_int( v:Vector ):Int
    {
        return Math.floor(v.y);
    }


    public static function get_length2D( v:Vector ):Float
    {

        return Math.sqrt( v.x * v.x + v.y * v.y );

    } //length2D


    public static function set_length2D( v:Vector, value:Float ):Vector
    {
        v = normalize2D(v);
        v = multiplyScalar2D(v , value);
        return v;

    } //length2D

    
    public static function set_angle_xy( v:Vector, value:Float ):Vector {

        var len:Float = get_length2D(v);

        v.set_xy(Math.cos(value) * len, Math.sin(value) * len);

        return v;

    } // set_angle_xy

    public static function get_angle_xy( v:Vector ):Float {

        return Math.atan2(v.y, v.x);

    } // get_angle_xy

    public static function normalize2D( v:Vector ):Vector
    {

        if ( get_length2D(v) != 0 ) {

            // v.set_xy( v.x / get_length2D(v), v.y / get_length2D(v) );
            v.x = v.x / get_length2D(v);
            v.y = v.y / get_length2D(v);

        } else {

            // v.set_xy(0, 0);
            v.x = 0;
            v.y = 0;

        }

        return v;
    } //normalize2D

    public static function multiplyScalar2D( v:Vector, value:Float ):Vector {

        v.set_xy( v.x * value, v.y * value );

        return v;

    } //multiplyScalar2D



}
