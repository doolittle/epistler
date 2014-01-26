package com.betweenpageandscreen.epistler.views.pages {
import com.betweenpageandscreen.binding.helpers.MaterialHelper;
import com.betweenpageandscreen.binding.views.pages.Epistle;

import flash.display.Bitmap;
import flash.display.Sprite;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.objects.primitives.Plane;


public class CustomEpistle extends Epistle{

  [Embed(source="../../../../../marker_outline.png")]
  private static var marker_mockup:Class;
  public static function get MARKER_MOCKUP():Bitmap {
    return new marker_mockup as Bitmap;
  }

  public function CustomEpistle(epistle_text:String, _justify:Boolean=true, _auto_position:Boolean = false){
    super(epistle_text, _justify, _auto_position);
    // rotationX = back-to-front
    // rotationY = rotation of marker (?)  i.e. clockwise
    // rotationZ = left-to-right, negative numbers tip up from right side
    preview_rotation = new Number3D(80,15, -5);
    preview_position = new Number3D(40,-10,700);
    preview_scale = 1.0;
  }

  override public function init(_container:Sprite, _marker:*):void {
    super.init(_container, _marker);

    var marker_mockup:Bitmap        = MARKER_MOCKUP;

    // Ugh, wrap mockup in sprite so helper can use it.
    // TODO: add helper method that accepts bitmaps directly.
    var marker_wrapper:Sprite = new Sprite;
    marker_wrapper.addChild(marker_mockup);

    var bmp:BitmapMaterial          = MaterialHelper.bitmap_mat(marker_wrapper,0,1);
    var mockup_plane:Plane          = new Plane(bmp,marker_wrapper.width/2,marker_wrapper.height/2,2,2);

    mockup_plane.scale = 0.4;
    mockup_plane.position = new Number3D(20,0,30);
    //mockup_plane.rotationZ+=90;

    marker.addChild(mockup_plane);
  }

  private var ticker_tick_switch:int = 120,
      ticker_count:int = -1,
      ticker_multiple:Number = 0.5;

  override public function tick():void {
    return;
    if (++ticker_count > ticker_tick_switch) {
      ticker_multiple*=-1
      ticker_count = 0;
    }
    marker.rotationY+=ticker_multiple;
  }
}
}
