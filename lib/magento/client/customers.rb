## API endpoints to customers

module Magento
  class Client
    # Module for customer access methods
    module Customers

      attr_reader :customer_filters

      # Get information about logged in customer
      def customer_me
        check_user_authorization
        get_wrapper('/V1/customers/me', default_headers)
      end

      # Edit logged in customer profile
      def edit_customer(payload)
        check_user_authorization
        put_wrapper('/V1/customers/me', payload.to_json, default_headers)
      end

      # Check email availability in system ( this email not exists in magento db )
      def email_available?(email, website_id)
        post_wrapper('/V1/customers/isEmailAvailable',
                     { customerEmail: email, websiteId: website_id }.to_json,
                     default_headers)
      end

      def activate_customer_account(key)
        check_user_authorization
        put_wrapper('/V1/customers/me/activate',
                    { confirmationKey: key }.to_json,
                    default_headers)
      end

      def activate_customer_account_by_email(email, key)
        put_wrapper("/V1/customers/#{email}/activate",
                    { confirmationKey: key }.to_json,
                    default_headers)
      end

      # Change customer password by passing old password and new
      def change_customer_password(old_password, new_password)
        check_user_authorization
        put_wrapper('/V1/customers/me/password',
                    { currentPassword: old_password,
                      newPassword: new_password }.to_json,
                    default_headers)
      end

      def change_customer_password_with_admin_access(email, new_password)
        headers = admin_headers
        post_wrapper('/V1/customers/newpassword',
                     { email: email, newPassword: new_password }.to_json,
                     headers)
      end

      def send_reset_password_email(email, website_id)
        put_wrapper('/V1/customers/password',
                    { email: email, template: 'email_reset',
                      websiteId: website_id }.to_json,
                    default_headers)
      end

      def resend_confirmation_email(email, website_id, redirect_url)
        post_wrapper('/V1/customers/confirm',
                     { email: email, redirectUrl: redirect_url,
                       websiteId: website_id }.to_json,
                     default_headers)
      end

      def validate_password_reset_token(customer_id, reset_token)
        get_wrapper("/V1/customers/#{customer_id}/password/resetLinkToken/#{reset_token}",
                    default_headers)
      end

      # Validate customer data before send it for example to create customer
      def validate_customer_data(payload)
        headers = admin_headers

        put_wrapper('/V1/customers/validate', payload.to_json, headers)
      end

      def get_customer_default_shipping_address
        check_user_authorization
        get_wrapper('/V1/customers/me/shippingAddress', default_headers)
      end

      # Delete customer in magento backend by id (e.g. for testing)
      def delete_customer_by_id(customer_id)
        headers = admin_headers

        delete_wrapper("/V1/customers/#{customer_id}", headers)
      end

      ## Similar to products filters
      def search_customers(page, per_page, filters = {})
        headers = admin_headers
        customer_filters = prepare_filters(filters, page, per_page)
        get_wrapper("/V1/customers/search?#{customer_filters}", headers)
      end
    end
  end
end