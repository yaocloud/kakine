module Kakine
  module Operation

    def set_remote_security_group_id(mod_content, tenant)
      if mod_content["rules"]["remote_group"]
        remote_security_group = Kakine::Resource.security_group(tenant, mod_content["rules"].delete("remote_group"))
        mod_content["rules"]["remote_group_id"] = remote_security_group.id
      end
      mod_content
    end
  end
end
