module ConnectionFind

  attr_accessor :components

  def initialize() 
    #@components = components.dup
    @parent = {} 
    @tree_size = {}
  end
  
  def connection(component_1, component_2)
    root_component_1 = find_root(component_1)
    root_component_2 = find_root(component_2)
     return nil if root_component_1 == root_component_2
    if @tree_size[root_component_1] < @tree_size[root_component_2]
      @parent[root_component_1] = root_component_2
      root = root_component_2
      @tree_size[root_component_2] += @tree_size[root_component_1]
    else
      @parent[root_component_2] = root_component_1
      root = root_component_1
      @tree_size[root_component_1] += @tree_size[root_component_2]
    end
   
    
  end  
  
  def find_root(component)
    set_parent_and_tree_size(component)  
    return component
  end
  
  
   def set_parent_and_tree_size(component)  
    @parent[component] ||= component
    @tree_size[component] ||= 1 
  end 
  
  def check_connected(component_1, component_2)
  begin
     if @tree_size[component_1] >@tree_size[component_2]
	     component_1,component_2=component_2,component_1
     end
     i=0     
    while component_1 != component_2  # stop at the top node where component id == parent id
	i=i+1
        component_1 = @parent[component_1]
    end
    return i
    rescue
       puts "Component missing in existing tree"
    end    
  end
  
  def connected?(component_1, component_2)
    check_connected(component_1, component_2)
  end
 
   
  end
 
 