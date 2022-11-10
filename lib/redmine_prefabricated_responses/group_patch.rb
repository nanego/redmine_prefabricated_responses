module RedminePrefabricatedResponses
  module GroupPatch
    def remove_references_before_destroy
      super
      Response.where(['assigned_to_id = ?', id]).update_all('assigned_to_id = NULL')
    end
	end
end