class UserMailer < ActionMailer::Base
   def registration_confirmation(user) 
   @message = "whatever you want to say here!, #{user.token}"
   mail(:from => "noreply@maestro-labs.com", :to => user.email, :subject => "Thank you for registration")
  end 
end
