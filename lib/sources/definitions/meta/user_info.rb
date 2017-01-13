
module MetaDefinitions
  class UserInfo < Definition

    def initialize()
      super("meta-user", "UserCRUD", MetaDefinitions::UserProperties)
    end
  end
end
