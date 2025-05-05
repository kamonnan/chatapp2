require 'rails_helper'

RSpec.describe "User can edit his username", type: :feature do
  context "when user exists" do
    let(:user) { FactoryBot.create(:user, username: "oldusername", password: "password") }

    context "when user logs in" do
      before do
        # Sign in the user
        visit new_user_session_path
        fill_in "Email", with: user.email
        fill_in "Password", with: "password"
        click_button "Log in"
      end

      it "allows user to change his username" do
        # Visit the user edit form
        visit edit_user_registration_path

        # Check current username in the form
        expect(find_field("Username").value).to eq(user.username)

        # Fill in new username and current password
        fill_in "Username", with: "newusername"
        fill_in "Current password", with: "password"
        click_button "Update"

        # Expect the page to reflect updated username
        expect(page).to have_content("Welcome, newusername")
        expect(user.reload.username).to eq("newusername")
      end

      it "does not allow blank username" do
        # Visit edit form and leave username blank
        visit edit_user_registration_path

        fill_in "Username", with: ""
        fill_in "Current password", with: "password"
        click_button "Update"

        # Expect error message
        expect(page).to have_content("Username can't be blank")
      end

      it "does not allow update without current password" do
        # Visit edit form without entering current password
        visit edit_user_registration_path

        fill_in "Username", with: "newusername"
        click_button "Update"

        # Expect error message
        expect(page).to have_content("Current password can't be blank")
      end

      context "when another user exists" do
        let!(:other_user) { FactoryBot.create(:user, username: "takenusername") }

        it "does not allow duplicate username" do
          # Try to update to a username that already exists
          visit edit_user_registration_path

          fill_in "Username", with: "takenusername"
          fill_in "Current password", with: "password"
          click_button "Update"

          # Expect uniqueness validation error
          expect(page).to have_content("Username has already been taken")
        end
      end

      it "reflects updated username in the UI" do
        # Update to a new username
        visit edit_user_registration_path

        fill_in "Username", with: "updateduser"
        fill_in "Current password", with: "password"
        click_button "Update"

        # Expect new username to appear in UI
        expect(page).to have_text(/Welcome, updateduser|updateduser/)
      end
    end
  end
end
