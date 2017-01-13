
module MetaDefinitions
  class UserInfo < Definition

    def initialize()
      super("user", "UserCRUD", MetaDefinitions::UserProperties)
    end
  end
end
