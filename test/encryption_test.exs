defmodule EncryptionTest do
  use ExUnit.Case
  doctest Encryption

  test "Tests encryption" do
    res = Encryption.encrypt!("testkey1", "teststring")
    assert Encryption.decrypt!("testkey1", res) == "teststring"
  end

  test "Tests unicode encryption" do
    res = Encryption.encrypt!("testkey1", "❌ 🚴")
    assert Encryption.decrypt!("testkey1", res) == "❌ 🚴"
  end

  test "Unicode key encryption" do
    res = Encryption.encrypt!("❌", "❌ 🚴")
    assert Encryption.decrypt!("❌", res) == "❌ 🚴"
  end
end
