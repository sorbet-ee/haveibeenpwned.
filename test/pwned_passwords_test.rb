# frozen_string_literal: true

require_relative "test_helper"

class PwnedPasswordsTest < Minitest::Test
  def test_pwned_passwords_has_check_method
    assert_respond_to HaveIBeenPwned::PwnedPasswords, :check
  end

  def test_pwned_passwords_has_check_hash_method
    assert_respond_to HaveIBeenPwned::PwnedPasswords, :check_hash
  end

  def test_pwned_passwords_has_range_search_method
    assert_respond_to HaveIBeenPwned::PwnedPasswords, :range_search
  end

  def test_ntlm_mode_not_implemented
    assert_raises(NotImplementedError) do
      HaveIBeenPwned::PwnedPasswords.check("password", mode: :ntlm)
    end
  end

  def test_invalid_mode
    assert_raises(ArgumentError) do
      HaveIBeenPwned::PwnedPasswords.check("password", mode: :invalid)
    end
  end
end
