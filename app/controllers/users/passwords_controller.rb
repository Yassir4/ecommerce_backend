class Users::PasswordsController < Devise::PasswordsController
    include RackSessionFix
    respond_to :json

    def update
        user = User.reset_password_by_token(reset_password_params)
        if user.errors.empty?
          render json: { message: 'Password has been reset successfully.' }, status: :ok
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
    end
    
    private
    def reset_password_params
        params.permit(:reset_password_token, :password, :password_confirmation)
    end

end