require 'minitest_helper'
require 'support/test_helper'

class TestKakineExporter < Minitest::Test
  def test_get_terraform
    assert_equal Kakine::Exporter::Terraform, Kakine::Exporter.get(:terraform)
  end

  def test_get_unknown
    assert_raises do
      Kakine::Exporter.get(:unknown_one)
    end
  end
end
