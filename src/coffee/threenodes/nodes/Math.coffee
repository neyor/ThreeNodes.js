define [
  'jQuery',
  'Underscore', 
  'Backbone',
  "text!templates/node.tmpl.html",
  "order!libs/jquery.tmpl.min",
  "order!libs/jquery.contextMenu",
  'order!threenodes/core/NodeFieldRack',
  'order!threenodes/utils/Utils',
], ($, _, Backbone, _view_node_template) ->
  "use strict"
  class ThreeNodes.nodes.types.Math.Sin extends ThreeNodes.NodeNumberSimple
    process_val: (num, i) =>
      Math.sin(num)
  
  class ThreeNodes.nodes.types.Math.Cos extends ThreeNodes.NodeNumberSimple
    process_val: (num, i) =>
      Math.cos(num)
  
  class ThreeNodes.nodes.types.Math.Tan extends ThreeNodes.NodeNumberSimple
    process_val: (num, i) =>
      Math.tan(num)
  
  class ThreeNodes.nodes.types.Math.Round extends ThreeNodes.NodeNumberSimple
    process_val: (num, i) =>
      Math.round(num)
  
  class ThreeNodes.nodes.types.Math.Ceil extends ThreeNodes.NodeNumberSimple
    process_val: (num, i) =>
      Math.ceil(num)
  
  class ThreeNodes.nodes.types.Math.Floor extends ThreeNodes.NodeNumberSimple
    process_val: (num, i) =>
      Math.floor(num)
  
  class ThreeNodes.NodeNumberParam1 extends ThreeNodes.NodeNumberSimple
    process_val: (num, numb, i) =>
      num + numb
    
    apply_num_to_vec2: (a, b, i) =>
      switch $.type(a)
        when "number" then new THREE.Vector2(@process_val(a, b.x, i), @process_val(a, b.y, i))
        when "object" then new THREE.Vector2(@process_val(a.x, b, i), @process_val(a.y, b, i))
    
    apply_num_to_vec3: (a, b, i) =>
      switch $.type(a)
        when "number" then new THREE.Vector3(@process_val(a, b.x, i), @process_val(a, b.y, i), @process_val(a, b.z, i))
        when "object" then new THREE.Vector3(@process_val(a.x, b, i), @process_val(a.y, b, i), @process_val(a.z, b, i))
      
    compute: =>
      res = []
      numItems = @rack.getMaxInputSliceCount()
      for i in [0..numItems]
        ref = @v_in.get(i)
        refb = @v_factor.get(i)
        switch $.type(ref)
          when "number"
            switch $.type(refb)
              when "number" then res[i] = @process_val(ref, refb, i)
              when "object"
                switch refb.constructor
                  when THREE.Vector2 then res[i] = @apply_num_to_vec2(ref, refb, i)
                  when THREE.Vector3 then res[i] = @apply_num_to_vec3(ref, refb, i)
          when "object"
            switch ref.constructor
              when THREE.Vector2
                switch $.type(refb)
                  when "number" then res[i] = @apply_num_to_vec2(ref, refb, i)
                  when "object" then res[i] = new THREE.Vector2(@process_val(ref.x, refb.x, i), @process_val(ref.y, refb.y, i))
              when THREE.Vector3
                switch $.type(refb)
                  when "number" then res[i] = @apply_num_to_vec3(ref, refb, i)
                  when "object" then res[i] = new THREE.Vector3(@process_val(ref.x, refb.x, i), @process_val(ref.y, refb.y, i), @process_val(ref.z, refb.z, i))
        
      #if @v_out.get() != res
      @v_out.set res
      true
  
  class ThreeNodes.nodes.types.Math.Mod extends ThreeNodes.NodeNumberParam1
    set_fields: =>
      super
      @v_factor = @rack.addField("y", {type: "Float", val: 2})
    process_val: (num, numb, i) =>
      num % numb
  
  class ThreeNodes.nodes.types.Math.Add extends ThreeNodes.NodeNumberParam1
    set_fields: =>
      super
      @v_factor = @rack.addField("y", {type: "Float", val: 1})
    process_val: (num, numb, i) =>
      num + numb
  
  class ThreeNodes.nodes.types.Math.Subtract extends ThreeNodes.NodeNumberParam1
    set_fields: =>
      super
      @v_factor = @rack.addField("y", {type: "Float", val: 1})
    process_val: (num, numb, i) =>
      num - numb
  
  class ThreeNodes.nodes.types.Math.Mult extends ThreeNodes.NodeNumberParam1
    set_fields: =>
      super
      @v_factor = @rack.addField("factor", {type: "Float", val: 2})
    
    process_val: (num, numb, i) =>
      num * numb
    
                
  class ThreeNodes.nodes.types.Math.Divide extends ThreeNodes.NodeNumberParam1
    set_fields: =>
      super
      @v_factor = @rack.addField("y", {type: "Float", val: 2})
    process_val: (num, numb, i) =>
      num / numb
  
  class ThreeNodes.nodes.types.Math.Min extends ThreeNodes.NodeNumberParam1
    set_fields: =>
      super
      @v_factor = @rack.addField("in2", {type: "Float", val: 0})
      @anim_obj = {in: 0, in2: 0}
    process_val: (num, numb, i) =>
      Math.min(num, numb)
  
  class ThreeNodes.nodes.types.Math.Max extends ThreeNodes.NodeNumberParam1
    set_fields: =>
      super
      @v_factor = @rack.addField("in2", {type: "Float", val: 0})
      @anim_obj = {in: 0, in2: 0}
    process_val: (num, numb, i) =>
      Math.max(num, numb)
      
  class ThreeNodes.nodes.types.Math.Attenuation extends ThreeNodes.NodeNumberParam1
    set_fields: =>
      super
      @def_val = @rack.addField("default", 0)
      @reset_val = @rack.addField("reset", false)
      @v_factor = @rack.addField("factor", 0.8)
      @val = @def_val.get()
    process_val: (num, numb, i) =>
      if @reset_val.get(i) == true
        @val = @def_val.get(i)
      @val = @val + (@v_in.get(i) - @val) * @v_factor.get(i)
      @val
