/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */
 
module skp.math.quaternion;

import std.algorithm : reduce;
import std.math : sin, sqrt;
import skp.math.angle;
import skp.math.axis;

/*********************
 * Quaternion.
 *
 * A quaternion, mainly used for local rotations.
 * Value semantic.
 */
struct SQuat {
    alias typeof(this) that;

    private SAxis3 _axis;
    private float _phi;

    @property {
        /*********************
         * Construct an identity quaternion.
         *
         * An identity quaternion is a quaternion set to rotate
         * over the X axis with a null angle.
         *
         * Returns: an identity quaternion
         */
        static that init() {
            return that(X_AXIS, .0f);
        }

        /*********************
         * Get the x component.
         *
         * Returns: the x component of the quaternion
         */
        float x() {
            return _axis.x;
        }
        
        /*********************
         * Get the y component.
         *
         * Returns: the y component of the quaternion
         */
        float y() {
            return _axis.y;
        }

        /*********************
         * Get the z component.
         *
         * Returns: the z component of the quaternion
         */
        float z() {
            return _axis.z;
        }

        /*********************
         * Get the w.
         *
         * Returns: the w component of the quaternion
         */
        float w() {
            return _phi;
        }
    }

    /*********************
     * Constructor.
     *
     * That constructor contructs a quaternion only if the axis
     * is normalized. If not, it violates an assertion.
     
     * Params:
     *     a = axis to turn around
     *     phi = angle of rotation
     */
    this(in SAxis3 a, rad_t phi) in {
        assert ( a.norm == 1.0f ); /* the axis has to be normalized */
    } body {
        _axis = a * sin(phi/2);
        _phi = phi;
    }

    /*********************
     * Normalize the quaternion.
     */
    void normalize() {
        //auto al = _axis.reduce!("a + b*b");
        auto al = _axis.x*_axis.x + _axis.y*_axis.y + _axis.z*_axis.z;
        auto l = sqrt(al + _phi*_phi);
        assert ( l != 0.0f );
        _axis /= l;
        _phi /= l;
    }

    /*********************
     * Assignement by multiplication operator.
     *
     * Params:
     *     rhs = quaternion to multiply by
     * Returns: the quaterion after it's been multiplied by rhs
     */
    ref that opOpAssign(string op)(in that rhs) if (op == "*") {
        _axis = SAxis3(
            _phi*rhs._axis.x + _axis.x*rhs._phi + _axis.y*rhs._axis.z - _axis.z*rhs._axis.y,
            _phi*rhs._axis.y + _axis.y*rhs._phi + _axis.z*rhs._axis.x - _axis.x*rhs._axis.z,
            _phi*rhs._axis.z + _axis.z*rhs._phi + _axis.x*rhs._axis.y - _axis.y*rhs._axis.x
        );
        _phi = _phi*rhs._phi - _axis.x*rhs._axis.x - _axis.y*rhs._axis.y - _axis.z*rhs._axis.z;
        normalize();
        return this;
    }
    
    /*********************
     * Multiplication operator.
     */
    that opBinary(string op)(ref const that rhs) const if (op == "*") {
        that r = this;
        r *= rhs;
        return r;
    }

    /*********************
     * 4x4 float matrix cast operator.
     *
     * That cast operator transforms the quaternion into a 4x4 float matrix.
     *
     * Returns: a 4x4 float matrix representation of the quaternion
     */
    auto opCast(SMat44)() const {
        SMat44 r = void;

        foreach (i; 0..3) {
            r[i,3] = r[3,i] = 0.0f;
        }

        r[0,0] = 1.0f - 2*_axis.y*_axis.y - 2*_axis.z*_axis.z;
        r[0,1] = 2*_axis.x*_axis.y - 2*_phi*_axis.z;
        r[0,2] = 2*_axis.x*_axis.z + 2*_phi*_axis.y;

        r[1,0] = 2*_axis.x*_axis.y + 2*_phi*_axis.z;
        r[1,1] = 1.0f - 2*_axis.x*_axis.x - 2*_axis.z*_axis.z;
        r[1,2] = 2*_axis.y*_axis.z - 2*_phi*_axis.x;

        r[2,0] = 2*_axis.x*_axis.z - 2*_phi*_axis.y;
        r[2,1] = 2*_axis.y*_axis.z + 2*_phi*_axis.x;
        r[2,2] = 1.0f - 2*_axis.x*_axis.x - 2*_axis.y*_axis.y;
        r[3,3] = 1.0f;

        return r;
    }
}
