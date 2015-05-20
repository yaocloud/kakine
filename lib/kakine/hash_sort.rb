class Hash
  def sg_rules_sort
    self.each do |sg|
      sg[1]['rules'].sort_by! do |rule|
        rule.inject(0) do |ascii,(k,v)|
          ascii += v.ord.to_i unless v.nil?
          ascii
        end
      end if !sg[1].nil? && !sg[1]['rules'].nil?
    end
    Hash[self]
  end
end
