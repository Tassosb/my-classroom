require "test_helper"

class DataSyncTest < ActiveSupport::TestCase
  test "Helper#sync_data!" do
    user = User.create!(uuid: 'abcd', email_address: 't@b.org', password_digest: 'password')

    data_from_google = {
      courses_attrs: [
        {
          google_id: '123',
          name: 'Precalculus',
          students_attrs: [
            {
              google_id: '4321',
              first_name: 'Harry',
              last_name: 'Potter'
            }
          ]
        },
        {
          google_id: '456',
          name: 'STAM',
          students_attrs: [
            {
              google_id: '4321',
              first_name: 'Harry',
              last_name: 'Potter'
            }
          ]
        }
      ]
    }

    DataSync::Helper.sync_data!(user, data_from_google)

    assert_equal 2, user.courses.count
    assert_equal 1, user.students.count

    precal = user.courses.first
    assert_equal '123', precal.google_id
    assert_equal 'Precalculus', precal.name 
    assert_equal 1, precal.students.count

    harry = precal.students.first
    assert_equal '4321', harry.google_id
    assert_equal 'Harry', harry.first_name
    assert_equal 'Potter', harry.last_name

    stam = user.courses.second
    assert_equal '456', stam.google_id
    assert_equal 'STAM', stam.name
    assert_equal 1, stam.students.count
    assert_equal harry, stam.students.first 

    DataSync::Helper.sync_data!(user, data_from_google)

    assert_equal 2, user.courses.count
    assert_equal 1, user.students.count
  end
end
