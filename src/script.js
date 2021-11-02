import './style.css'
import * as THREE from 'three'
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls.js'
import * as dat from 'dat.gui'
import {Stats} from "./Stats.js"

import vertShader from "./vert.glsl"
import fragShader from "./frag.glsl"

		
let camera, scene, renderer;

var stats = new Stats();

stats.showPanel(0);
document.body.appendChild(stats.dom);

document.addEventListener('contextmenu', event => event.preventDefault(),false);

function main() {

    // ROLL THE SCENE			

    scene = new THREE.Scene({ antialias: true });
    scene.background = new THREE.Color( 0x3AE9F3 );


    // CAMERA SETUP

    camera = new THREE.PerspectiveCamera( 80, window.innerWidth / window.innerHeight, 0.25, 2000 );
    camera.position.set(0.,0.,4.);

    var vFOV = camera.fov * Math.PI / 180;
    var h = 2 * Math.tan( vFOV / 2 ) * camera.position.z+100;
    var w = h * camera.aspect;

    const container = document.createElement( 'div' );
    document.body.appendChild( container );

    renderer = new THREE.WebGLRenderer({powerPreference: "high-performance",antialias: false});
    renderer.setPixelRatio( window.devicePixelRatio );
    renderer.setSize( window.innerWidth, window.innerHeight );
    container.appendChild( renderer.domElement );

    // ORBIT CONTROLS

    const controls = new OrbitControls( camera, renderer.domElement );
    controls.update();

    // CLOUD BOX

    // var material = new THREE.MeshBasicMaterial({color: "red"});

    var geometry = new THREE.BoxGeometry(4,2,2);
    var material = new THREE.ShaderMaterial({
        uniforms: {
            iTime: {value: 0.},
        },
        vertexShader: vertShader,
        fragmentShader: fragShader,
        transparent: true,

        // blending: THREE.AdditiveBlending,
        // blending: THREE.NoBlending,
        // blending: THREE.MultiplyBlending
    })
    var cloudBox = new THREE.Mesh(geometry,material);
    scene.add(cloudBox);


    // WINDOW RESIZE

    window.addEventListener( 'resize', onWindowResize, false );

    function onWindowResize(){

        var width = window.innerWidth;
        var height = window.innerHeight;

        camera.aspect = width/height;
        camera.updateProjectionMatrix();

        w = h*camera.aspect;

        renderer.setSize( width,height);
    }

    // RENDER LOOP

    function render(time)
    {   
        stats.begin();

        material.uniforms.iTime.value = time*0.001;

        renderer.render(scene,camera);

        stats.end();

        requestAnimationFrame ( render );

    }

    requestAnimationFrame ( render );

}

main();




