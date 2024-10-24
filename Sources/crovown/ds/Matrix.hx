package crovown.ds;

class Matrix {
    public final w = 4;
    public final h = 4;

    public var _00:Float;
    public var _10:Float;
    public var _20:Float;
    public var _30:Float;
    public var _01:Float;
    public var _11:Float;
    public var _21:Float;
    public var _31:Float;
    public var _02:Float;
    public var _12:Float;
    public var _22:Float;
    public var _32:Float;
    public var _03:Float;
    public var _13:Float;
    public var _23:Float;
    public var _33:Float;

    public function new(
        _00 = 0.0, _10 = 0.0, _20 = 0.0, _30 = 0.0,
        _01 = 0.0, _11 = 0.0, _21 = 0.0, _31 = 0.0,
        _02 = 0.0, _12 = 0.0, _22 = 0.0, _32 = 0.0,
        _03 = 0.0, _13 = 0.0, _23 = 0.0, _33 = 0.0) {
        this._00 = _00;
        this._10 = _10;
        this._20 = _20;
        this._30 = _30;
        this._01 = _01;
        this._11 = _11;
        this._21 = _21;
        this._31 = _31;
        this._02 = _02;
        this._12 = _12;
        this._22 = _22;
        this._32 = _32;
        this._03 = _03;
        this._13 = _13;
        this._23 = _23;
        this._33 = _33;
    }

    public static inline function Identity() {
        return new Matrix().setIdentity();
    }

    public static inline function Translation(x = 0.0, y = 0.0, z = 0.0, w = 1.0) {
        return Identity().setTranslation(x, y, z, w);
    }


    public static inline function RotationX(alpha = 0.0) {
        return new Matrix().setRotationX(alpha);
    }

    public static inline function RotationY(alpha = 0.0) {
        return new Matrix().setRotationY(alpha);
    }

    public static inline function RotationZ(alpha = 0.0) {
        return new Matrix().setRotationZ(alpha);
    }

    public static inline function Rotation(x = 0.0, y = 0.0, z = 0.0) {
        return new Matrix().setRotation(x, y, z);
    }

    public static inline function Scale(x = 1.0, y = 1.0, z = 1.0) {
        return new Matrix(
            x, 0, 0, 0,
            0, y, 0, 0,
            0, 0, z, 0,
            0, 0, 0, 1
        );
    }

    // @todo setOrthogonal
    public static inline function Orthogonal(l:Float, r:Float, b:Float, t:Float, n:Float, f:Float) {
        var tx:Float = -(r + l) / (r - l);
        var ty:Float = -(t + b) / (t - b);
        var tz:Float = -(f + n) / (f - n);
        return new Matrix(
            2 / (r - l), 0,             0,            tx,
            0,           2.0 / (t - b), 0,            ty,
            0,           0,             -2 / (f - n), tz,
            0,           0,             0,            1
        );
    }

    // https://learnwebgl.brown37.net/08_projections/projections_perspective.html
    public static inline function Perspective(fovY:Float, aspect:Float, n:Float, f:Float) {
        var t = n * Math.tan(fovY / 2);
        var b = -t;
        var r = t * aspect;
        var l = -r;
        return Frustum(l, r, b, t, n, f);
    }

    // https://songho.ca/opengl/gl_projectionmatrix.html
    public static inline function Frustum(l:Float, r:Float, b:Float, t:Float, n:Float, f:Float) {
        return new Matrix(
            2 * n / (r - l), 0,               (r + l) / (r - l),  0,
            0,               2 * n / (t - b), (t + b) / (t - b),  0,
            0,               0,               -(f + n) / (f - n), -2 * f * n / (f - n),
            0,               0,               -1,                 0
        );
    }

    // https://learnwebgl.brown37.net/08_projections/projections_perspective.html
    // public static inline function Frustum(l:Float, r:Float, b:Float, t:Float, n:Float, f:Float) {
    //     return new Matrix(
    //         2 * n / (r - l), 0,               0,                  -n * (r + l) / (r - l),
    //         0,               2 * n / (t - b), 0,                  -n * (t + b)/(t - b),
    //         0,               0,               -(f + n) / (f - n), 2 * f * n / (n- f),
    //         0,               0,               -1,                 0
    //     );
    // }

    public static inline function LookAt(eye:Vector, at:Vector, up:Vector) {
        var zaxis = at.Sub(eye).normalize();
        var xaxis = zaxis.Cross(up).normalize();
        var yaxis = xaxis.Cross(zaxis);
        return new Matrix(
            xaxis.x,  xaxis.y,  xaxis.z,  -xaxis.dot(eye),
            yaxis.x,  yaxis.y,  yaxis.z,  -yaxis.dot(eye),
            -zaxis.x, -zaxis.y, -zaxis.z, zaxis.dot(eye),
            0,        0,        0,        1
        );
    }

    public inline function fromArray(v:Array<Float>) {
        _00 = v[0];  _10 = v[1];  _20 = v[2];  _30 = v[3];
        _01 = v[4];  _11 = v[5];  _21 = v[6];  _31 = v[7];
        _02 = v[8];  _12 = v[9];  _22 = v[10]; _32 = v[11];
        _03 = v[12]; _13 = v[13]; _23 = v[14]; _33 = v[15];
        return this;
    }

    public inline function toArray(v:Array<Float>) {
        v[0] = _00;  v[1] = _10;  v[2] = _20;  v[3] = _30;
        v[4] = _01;  v[5] = _11;  v[6] = _21;  v[7] = _31;
        v[8] = _02;  v[9] = _12;  v[10] = _22; v[11] = _32;
        v[12] = _03; v[13] = _13; v[14] = _23; v[15] = _33;
        return v;
    }

    public function equals(v:Matrix, epsilon = 1e-6) {
        return
            Math.abs(_00 - v._00) < epsilon &&
            Math.abs(_10 - v._10) < epsilon &&
            Math.abs(_20 - v._20) < epsilon &&
            Math.abs(_30 - v._30) < epsilon &&
            Math.abs(_01 - v._01) < epsilon &&
            Math.abs(_11 - v._11) < epsilon &&
            Math.abs(_21 - v._21) < epsilon &&
            Math.abs(_31 - v._31) < epsilon &&
            Math.abs(_02 - v._02) < epsilon &&
            Math.abs(_12 - v._12) < epsilon &&
            Math.abs(_22 - v._22) < epsilon &&
            Math.abs(_32 - v._32) < epsilon &&
            Math.abs(_03 - v._03) < epsilon &&
            Math.abs(_13 - v._13) < epsilon &&
            Math.abs(_23 - v._23) < epsilon &&
            Math.abs(_33 - v._33) < epsilon;
    }

    public function toString() {
        return
            '[[${_00}, ${_10}, ${_20}, ${_30}]\n' +
            '[${_01}, ${_11}, ${_21}, ${_31}]\n' +
            '[${_02}, ${_12}, ${_22}, ${_32}]\n' +
            '[${_03}, ${_13}, ${_23}, ${_33}]]';
    }

    public inline function load(v:Matrix) {
        _00 = v._00;
        _10 = v._10;
        _20 = v._20;
        _30 = v._30;
        _01 = v._01;
        _11 = v._11;
        _21 = v._21;
        _31 = v._31;
        _02 = v._02;
        _12 = v._12;
        _22 = v._22;
        _32 = v._32;
        _03 = v._03;
        _13 = v._13;
        _23 = v._23;
        _33 = v._33;
        return this;
    }

    public inline function set(
        _00 = 0.0, _10 = 0.0, _20 = 0.0, _30 = 0.0,
        _01 = 0.0, _11 = 0.0, _21 = 0.0, _31 = 0.0,
        _02 = 0.0, _12 = 0.0, _22 = 0.0, _32 = 0.0,
        _03 = 0.0, _13 = 0.0, _23 = 0.0, _33 = 0.0) {
        this._00 = _00;
        this._10 = _10;
        this._20 = _20;
        this._30 = _30;
        this._01 = _01;
        this._11 = _11;
        this._21 = _21;
        this._31 = _31;
        this._02 = _02;
        this._12 = _12;
        this._22 = _22;
        this._32 = _32;
        this._03 = _03;
        this._13 = _13;
        this._23 = _23;
        this._33 = _33;
        return this;
    }

    public inline function setIdentity() {
        return set(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        );
    }

    public inline function setTranslation(x = 0.0, y = 0.0, z = 0.0, w = 1.0) {
        _30 = x;
        _31 = y;
        _32 = z;
        _33 = w;
        return this;
    }

    public inline function setRotationX(alpha = 0.0) {
        var ca = Math.cos(alpha);
        var sa = Math.sin(alpha);
        return set(
            1,   0,   0,   0,
            0,   ca,  -sa, 0,
            0,   sa,  ca,  0,
            0,   0,   0,   1
        );
    }

    public inline function setRotationY(alpha = 0.0) {
        var ca = Math.cos(alpha);
        var sa = Math.sin(alpha);
        return set(
            ca,  0,   sa,  0,
            0,   1,   0,   0,
            -sa, 0,   ca,  0,
            0,   0,   0,   1
        );
    }

    public inline function setRotationZ(alpha = 0.0) {
        var ca = Math.cos(alpha);
        var sa = Math.sin(alpha);
        return set(
            ca,  -sa, 0,   0,
            sa,  ca,  0,   0,
            0,   0,   1,   0,
            0,   0,   0,   1
        );
    }

    public inline function setRotation(x = 0.0, y = 0.0, z = 0.0) {
        var sy = Math.sin(x);
        var cy = Math.cos(x);
        var sx = Math.sin(y);
        var cx = Math.cos(y);
        var sz = Math.sin(z);
        var cz = Math.cos(z);
        return set(
            cx * cy, cx * sy * sz - sx * cz, cx * sy * cz + sx * sz, 0,
            sx * cy, sx * sy * sz + cx * cz, sx * sy * cz - cx * sz, 0,
            -sy,     cy * sz,                cy * cz,                0,
            0,       0,                      0,                      1
        );
    }

    // @todo
    public function setRotationAxis() {
        
    }

    public function setScale(x = 1.0, y = 1.0, z = 1.0) {
        return set(
            x, 0, 0, 0,
            0, y, 0, 0,
            0, 0, z, 0,
            0, 0, 0, 1
        );
    }


    public inline function zeros() {
        return set(
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0
        );
    }

    public inline function ones() {
        return set(
            1, 1, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 1
        );
    }

    // @todo
    public inline function compose(location, rotation, scale) {
        
    }

    // @todo
    public inline function decompose() {
        
    }
    
    public inline function clone() {
        return new Matrix(
            _00, _10, _20, _30,
            _01, _11, _21, _31,
            _02, _12, _22, _32,
            _03, _13, _23, _33
        );
    }
    
    public function add(v:Matrix) {
        _00 += v._00; _10 += v._10; _20 += v._20; _30 += v._30;
        _01 += v._01; _11 += v._11; _21 += v._21; _31 += v._31;
        _02 += v._02; _12 += v._12; _22 += v._22; _32 += v._32;
        _03 += v._03; _13 += v._13; _23 += v._23; _33 += v._33;
        return this;
    }

    public function Add(v:Matrix) {
        return clone().add(v);
    }

    public function sub(v:Matrix) {
        _00 -= v._00; _10 -= v._10; _20 -= v._20; _30 -= v._30;
        _01 -= v._01; _11 -= v._11; _21 -= v._21; _31 -= v._31;
        _02 -= v._02; _12 -= v._12; _22 -= v._22; _32 -= v._32;
        _03 -= v._03; _13 -= v._13; _23 -= v._23; _33 -= v._33;
        return this;
    }

    public function Sub(v:Matrix) {
        return clone().sub(v);
    }

    public function multVal(v:Float) {
        _00 *= v; _10 *= v; _20 *= v; _30 *= v;
        _01 *= v; _11 *= v; _21 *= v; _31 *= v;
        _02 *= v; _12 *= v; _22 *= v; _32 *= v;
        _03 *= v; _13 *= v; _23 *= v; _33 *= v;
        return this;
    }

    public function MultVal(v:Float) {
        return clone().multVal(v);
    }

    public function multMat(v:Matrix) {
        return set(
            _00 * v._00 + _10 * v._01 + _20 * v._02 + _30 * v._03,
            _00 * v._10 + _10 * v._11 + _20 * v._12 + _30 * v._13,
            _00 * v._20 + _10 * v._21 + _20 * v._22 + _30 * v._23,
            _00 * v._30 + _10 * v._31 + _20 * v._32 + _30 * v._33,
            
            _01 * v._00 + _11 * v._01 + _21 * v._02 + _31 * v._03,
            _01 * v._10 + _11 * v._11 + _21 * v._12 + _31 * v._13,
            _01 * v._20 + _11 * v._21 + _21 * v._22 + _31 * v._23,
            _01 * v._30 + _11 * v._31 + _21 * v._32 + _31 * v._33,
            
            _02 * v._00 + _12 * v._01 + _22 * v._02 + _32 * v._03,
            _02 * v._10 + _12 * v._11 + _22 * v._12 + _32 * v._13,
            _02 * v._20 + _12 * v._21 + _22 * v._22 + _32 * v._23,
            _02 * v._30 + _12 * v._31 + _22 * v._32 + _32 * v._33,
            
            _03 * v._00 + _13 * v._01 + _23 * v._02 + _33 * v._03,
            _03 * v._10 + _13 * v._11 + _23 * v._12 + _33 * v._13,
            _03 * v._20 + _13 * v._21 + _23 * v._22 + _33 * v._23,
            _03 * v._30 + _13 * v._31 + _23 * v._32 + _33 * v._33
        );
    }

    public function MultMat(v:Matrix) {
        return clone().multMat(v);
    }

    public inline function multVec(v:Vector) {
        return v.set(
            _00 * v.x + _10 * v.y + _20 * v.z + _30 * v.w,
            _01 * v.x + _11 * v.y + _21 * v.z + _31 * v.w,
            _02 * v.x + _12 * v.y + _22 * v.z + _32 * v.w,
            _03 * v.x + _13 * v.y + _23 * v.z + _33 * v.w
        );
    }

    public inline function MultVec(v:Vector) {
        return multVec(v.clone());
    }

    public function right() {
        return new Vector(_00, _01, _02);
    }

    public function look() {
        return new Vector(_10, _11, _12);
    }

    public function up() {
        return new Vector(_20, _21, _22);
    }

    public function getLocation() {
        return new Vector(_30, _31, _32, _33);
    }

    public function getScale() {
        return new Vector(
            Math.sqrt(_00 * _00 + _10 * _10 + _20 * _20),
            Math.sqrt(_01 * _01 + _11 * _11 + _21 * _21),
            Math.sqrt(_02 * _02 + _12 * _12 + _22 * _22),
            1
        );
    }

    // @todo
    public function getRotation() {
        
    }

    public function translate(x = 0.0, y = 0.0, z = 0.0) {
        _00 += x * _03; _10 += x * _13; _20 += x * _23; _30 += x * _33;
        _01 += y * _03; _11 += y * _13; _21 += y * _23; _31 += y * _33;
        _02 += z * _03; _12 += z * _13; _22 += z * _23; _32 += z * _33;
        return this;
    }

    public function scale(x = 1.0, y = 1.0, z = 1.0) {
        _00 *= x;
    	_01 *= x;
    	_02 *= x;
    	_03 *= x;
    	_10 *= y;
    	_11 *= y;
    	_12 *= y;
    	_13 *= y;
    	_20 *= z;
    	_21 *= z;
    	_22 *= z;
    	_23 *= z;
        return this;
    }

    public function rotate(x:Float, y:Float, z:Float) {
        var rot = Matrix.Rotation(x, y, z);
        multMat(rot);
    }

    public function Transpose() {
        return new Matrix(
            _00, _01, _02, _03,
            _10, _11, _12, _13,
            _20, _21, _22, _23,
            _30, _31, _32, _33
        );
    }

    public function Transpose3x3() {
        return new Matrix(
            _00, _01, _02, _30,
            _10, _11, _12, _31,
            _20, _21, _22, _32,
            _03, _13, _23, _33
        );
    }

    public function trace() {
        return _00 + _11 + _22 + _33;
    }

    public function cofactor(m0:Float, m1:Float, m2:Float, m3:Float, m4:Float, m5:Float, m6:Float, m7:Float, m8:Float):Float {
        return m0 * (m4 * m8 - m5 * m7) - m1 * (m3 * m8 - m5 * m6) + m2 * (m3 * m7 - m4 * m6);
    }

    public function determinant() {
        var c00 = cofactor(_11, _21, _31, _12, _22, _32, _13, _23, _33);
        var c01 = cofactor(_10, _20, _30, _12, _22, _32, _13, _23, _33);
        var c02 = cofactor(_10, _20, _30, _11, _21, _31, _13, _23, _33);
        var c03 = cofactor(_10, _20, _30, _11, _21, _31, _12, _22, _32);
        return _00 * c00 - _01 * c01 + _02 * c02 - _03 * c03;
    }

    // /*
    public function inverse() {
        var c00 = cofactor(_11, _21, _31, _12, _22, _32, _13, _23, _33);
        var c01 = cofactor(_10, _20, _30, _12, _22, _32, _13, _23, _33);
        var c02 = cofactor(_10, _20, _30, _11, _21, _31, _13, _23, _33);
        var c03 = cofactor(_10, _20, _30, _11, _21, _31, _12, _22, _32);

        var det = _00 * c00 - _01 * c01 + _02 * c02 - _03 * c03;
        if (Math.abs(det) < 1e-6) return setIdentity();

        var c10 = cofactor(_01, _21, _31, _02, _22, _32, _03, _23, _33);
        var c11 = cofactor(_00, _20, _30, _02, _22, _32, _03, _23, _33);
        var c12 = cofactor(_00, _20, _30, _01, _21, _31, _03, _23, _33);
        var c13 = cofactor(_00, _20, _30, _01, _21, _31, _02, _22, _32);

        var c20 = cofactor(_01, _11, _31, _02, _12, _32, _03, _13, _33);
        var c21 = cofactor(_00, _10, _30, _02, _12, _32, _03, _13, _33);
        var c22 = cofactor(_00, _10, _30, _01, _11, _31, _03, _13, _33);
        var c23 = cofactor(_00, _10, _30, _01, _11, _31, _02, _12, _32);

        var c30 = cofactor(_01, _11, _21, _02, _12, _22, _03, _13, _23);
        var c31 = cofactor(_00, _10, _20, _02, _12, _22, _03, _13, _23);
        var c32 = cofactor(_00, _10, _20, _01, _11, _21, _03, _13, _23);
        var c33 = cofactor(_00, _10, _20, _01, _11, _21, _02, _12, _22);

        var invdet = 1.0 / det;
        return set(
            c00 * invdet,  -c01 * invdet, c02 * invdet,  -c03 * invdet,
            -c10 * invdet, c11 * invdet,  -c12 * invdet, c13 * invdet,
            c20 * invdet,  -c21 * invdet, c22 * invdet,  -c23 * invdet,
            -c30 * invdet, c31 * invdet,  -c32 * invdet, c33 * invdet
        );
    }
    // */

    /*
    public function inverse() {
        var m = this.clone();
        var m00 = m._00; var m01 = m._01; var m02 = m._02; var m03 = m._03;
		var m10 = m._10; var m11 = m._11; var m12 = m._12; var m13 = m._13;
		var m20 = m._20; var m21 = m._21; var m22 = m._22; var m23 = m._23;
		var m30 = m._30; var m31 = m._31; var m32 = m._32; var m33 = m._33;

		_00 = m11 * m22 * m33 - m11 * m23 * m32 - m21 * m12 * m33 + m21 * m13 * m32 + m31 * m12 * m23 - m31 * m13 * m22;
		_01 = -m01 * m22 * m33 + m01 * m23 * m32 + m21 * m02 * m33 - m21 * m03 * m32 - m31 * m02 * m23 + m31 * m03 * m22;
		_02 = m01 * m12 * m33 - m01 * m13 * m32 - m11 * m02 * m33 + m11 * m03 * m32 + m31 * m02 * m13 - m31 * m03 * m12;
		_03 = -m01 * m12 * m23 + m01 * m13 * m22 + m11 * m02 * m23 - m11 * m03 * m22 - m21 * m02 * m13 + m21 * m03 * m12;
		_10 = -m10 * m22 * m33 + m10 * m23 * m32 + m20 * m12 * m33 - m20 * m13 * m32 - m30 * m12 * m23 + m30 * m13 * m22;
		_11 = m00 * m22 * m33 - m00 * m23 * m32 - m20 * m02 * m33 + m20 * m03 * m32 + m30 * m02 * m23 - m30 * m03 * m22;
		_12 = -m00 * m12 * m33 + m00 * m13 * m32 + m10 * m02 * m33 - m10 * m03 * m32 - m30 * m02 * m13 + m30 * m03 * m12;
		_13 =  m00 * m12 * m23 - m00 * m13 * m22 - m10 * m02 * m23 + m10 * m03 * m22 + m20 * m02 * m13 - m20 * m03 * m12;
		_20 = m10 * m21 * m33 - m10 * m23 * m31 - m20 * m11 * m33 + m20 * m13 * m31 + m30 * m11 * m23 - m30 * m13 * m21;
		_21 = -m00 * m21 * m33 + m00 * m23 * m31 + m20 * m01 * m33 - m20 * m03 * m31 - m30 * m01 * m23 + m30 * m03 * m21;
		_22 = m00 * m11 * m33 - m00 * m13 * m31 - m10 * m01 * m33 + m10 * m03 * m31 + m30 * m01 * m13 - m30 * m03 * m11;
		_23 =  -m00 * m11 * m23 + m00 * m13 * m21 + m10 * m01 * m23 - m10 * m03 * m21 - m20 * m01 * m13 + m20 * m03 * m11;
		_30 = -m10 * m21 * m32 + m10 * m22 * m31 + m20 * m11 * m32 - m20 * m12 * m31 - m30 * m11 * m22 + m30 * m12 * m21;
		_31 = m00 * m21 * m32 - m00 * m22 * m31 - m20 * m01 * m32 + m20 * m02 * m31 + m30 * m01 * m22 - m30 * m02 * m21;
		_32 = -m00 * m11 * m32 + m00 * m12 * m31 + m10 * m01 * m32 - m10 * m02 * m31 - m30 * m01 * m12 + m30 * m02 * m11;
		_33 = m00 * m11 * m22 - m00 * m12 * m21 - m10 * m01 * m22 + m10 * m02 * m21 + m20 * m01 * m12 - m20 * m02 * m11;

		var det = m00 * _00 + m01 * _10 + m02 * _20 + m03 * _30;
		if (Math.abs(det) < 1e-6) {
			return setIdentity();
		}

		det = 1.0 / det;
		_00 *= det;
		_01 *= det;
		_02 *= det;
		_03 *= det;
		_10 *= det;
		_11 *= det;
		_12 *= det;
		_13 *= det;
		_20 *= det;
		_21 *= det;
		_22 *= det;
		_23 *= det;
		_30 *= det;
		_31 *= det;
		_32 *= det;
		_33 *= det;
        return this;
    }
    */

    public function Inverse() {
        return clone().inverse();
    }

    public function isIdentity() {
        if (_00 != 1 || _10 != 0 || _20 != 0 || _30 != 0) return false;
        if (_00 != 0 || _10 != 1 || _20 != 0 || _30 != 0) return false;
        if (_00 != 0 || _10 != 0 || _20 != 1 || _30 != 0) return false;
        if (_00 != 0 || _10 != 0 || _20 != 0 || _30 != 1) return false;
        return true;
    }

    public function isAlmostIdentity(e = 1e-6) {
        if (Math.abs(_00 - 1) > e || Math.abs(_10) > e     || Math.abs(_20) > e     || Math.abs(_30) > e) return false;
        if (Math.abs(_00) > e     || Math.abs(_10 - 1) > e || Math.abs(_20) > e     || Math.abs(_30) > e) return false;
        if (Math.abs(_00) > e     || Math.abs(_10) > e     || Math.abs(_20 - 1) > e || Math.abs(_30) > e) return false;
        if (Math.abs(_00) > e     || Math.abs(_10) > e     || Math.abs(_20) > e     || Math.abs(_30 - 1) > e) return false;
        return true;
    }

    // @todo color matrix
}