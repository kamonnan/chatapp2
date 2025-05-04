require 'rails_helper'

RSpec.describe "User username editing", type: :feature do
  let(:user) { FactoryBot.create(:user, username: "oldusername", password: "password") }
  
  before do
    # Sign in the user
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"
  end

  scenario "user can edit username" do
    visit edit_user_registration_path
    
    expect(find_field("Username").value).to eq(user.username)
    
    fill_in "Username", with: "newusername"
    fill_in "Current password", with: "password"
    click_button "Update"
    
    expect(page).to have_content("Welcome, newusername")
    expect(user.reload.username).to eq("newusername")

    puts "\e[32m[PASS]\e[0m user can edit username ✅"
  end

  scenario "user cannot update with invalid username" do
    visit edit_user_registration_path

    fill_in "Username", with: ""
    fill_in "Current password", with: "password"
    click_button "Update"
    
    expect(page).to have_content("Username can't be blank")

    puts "\e[32m[PASS]\e[0m user cannot update with invalid username ✅"
  end

  scenario "user cannot update without current password" do
    visit edit_user_registration_path

    fill_in "Username", with: "newusername"
    # No current password
    click_button "Update"

    expect(page).to have_content("Current password can't be blank")

    puts "\e[32m[PASS]\e[0m user cannot update without current password ✅"
  end

  scenario "username is unique" do
    other_user = FactoryBot.create(:user, username: "takenusername")

    visit edit_user_registration_path

    fill_in "Username", with: "takenusername"
    fill_in "Current password", with: "password"
    click_button "Update"

    expect(page).to have_content("Username has already been taken")

    puts "\e[32m[PASS]\e[0m username is unique ✅"
  end

  scenario "updated username is reflected in the UI" do
    visit edit_user_registration_path

    fill_in "Username", with: "updateduser"
    fill_in "Current password", with: "password"
    click_button "Update"

    # สมมุติว่าหลังจากอัปเดต username แล้ว หน้าเว็บเปลี่ยนไปหน้าโปรไฟล์หรือหน้าหลัก
    # ที่มีข้อความแสดงชื่อใหม่
    expect(page).to have_text(/Welcome, updateduser|updateduser/)

    puts "\e[32m[PASS]\e[0m updated username is reflected in the UI ✅"
  end

end