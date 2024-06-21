// インボリュート歯車(2D)
module inv_gear(m,z,alpha){
    d_p = z*m; // 基準円の直径
    d_k = d_p + 2*m; // 歯先円の直径
    d_f = d_p - 2.5*m; // 歯底円の直径
    d_b = d_p * cos(alpha); // 基礎円の直径
    
    // 半径バージョン
    r_p = d_p / 2;
    r_k = d_k / 2;
    r_f = d_f / 2;
    r_b = d_b / 2;

    s = m*PI / 2; // 歯厚

    // 角度をラジアンとして扱うラッパー関数群
    function rad_cos(a) = cos(a*180/PI);
    function rad_sin(a) = sin(a*180/PI);
    function rad_tan(a) = tan(a*180/PI);
    function rad_acos(r) = acos(r)*PI/180;

    // インボリュート曲線を計算する関数群
    function theta(r) = rad_acos(r_b/r);
    function inv(a) = rad_tan(a) - a;
    function x(r) = r*rad_cos(inv(theta(r)));
    function y(r) = r*rad_sin(inv(theta(r)));

    // なんかいい感じに使える値
    theta_b = s/r_b + 2*inv(alpha*(PI/180));
    phi = 360/z - 180*theta_b/PI;

    // x,yを原点中心としてa°回転させる関数
    function rotation(x,y,a) = [x*rad_cos(a)-y*rad_sin(a),x*rad_sin(a)+y*rad_cos(a)];
    
    // 歯先
    module cog(){
        step = (r_k-r_b)/10;
        points = [[0,0],for(i=[r_b:step:r_k]) [x(i),y(i)], [x(r_k),y(r_k)], for(i=[r_k:-step:r_b]) rotation(x(i),-y(i),theta_b), rotation(x(r_b),-y(r_b),theta_b)];
        polygon(points);
    }
    
    rotate([0,0,phi/2]) union(){
        circle(r=r_f,$fa=0.1);
        for(i=[0:360/z:361]) rotate([0,0,i]) cog();
    }
    
}

// 基本球状歯車(Basic spherical gear)
module sph_gear(m,z,alpha){
    d_p = z*m; // 基準円の直径
    d_k = d_p + 2*m; // 歯先円の直径
    d_f = d_p - 2.5*m; // 歯底円の直径
    d_b = d_p * cos(alpha); // 基礎円の直径

    r_p = d_p / 2;
    r_k = d_k / 2;
    r_f = d_f / 2;
    r_b = d_b / 2;
    
    rotate([0,90,0]) rotate_extrude(){
        difference(){
            inv_gear(m,z,alpha);
            translate([-r_k,-r_k,0]) square([r_k,d_k]);
        }
    }
}

// 直交球状歯車(Cross spherical gear)
module CS_gear(m,z,alpha){
    d_p = z*m; // 基準円の直径
    d_k = d_p + 2*m; // 歯先円の直径
    d_f = d_p - 2.5*m; // 歯底円の直径
    d_b = d_p * cos(alpha); // 基礎円の直径

    r_p = d_p / 2;
    r_k = d_k / 2;
    r_f = d_f / 2;
    r_b = d_b / 2;
    
    intersection(){
        sph_gear(m,z,alpha);
        rotate([0,0,90]) sph_gear(m,z,alpha);
    }
}

// 鞍状歯車(Monopole gear)
module mpl_gear(m,z,alpha){
    d_p = z*m; // 基準円の直径
    d_k = d_p + 2*m; // 歯先円の直径
    d_f = d_p - 2.5*m; // 歯底円の直径
    d_b = d_p * cos(alpha); // 基礎円の直径

    r_p = d_p / 2;
    r_k = d_k / 2;
    r_f = d_f / 2;
    r_b = d_b / 2;
    
    step = 360/z;
    
    difference(){
        translate([0,0,-r_p/2]) linear_extrude(r_p) circle((3-sqrt(3))*r_k/2);
        for(i=[0:step:360]){
            translate([3*r_p*cos(i)/2,3*r_p*sin(i)/2,0]){
                rotate([0,0,3*i/2+180]) sph_gear(m,z,alpha);
            }
        }
    }
}