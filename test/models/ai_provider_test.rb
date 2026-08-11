require "test_helper"

class AiProviderTest < ActiveSupport::TestCase
  test "build returns the demo provider by default" do
    provider = Ai::Provider.build(config: {}, env: {})
    assert_instance_of Ai::Demo, provider
  end

  test "build returns the openai compatible provider when configured" do
    provider = Ai::Provider.build(
      config: { provider: "openai_compatible" },
      env: {}
    )
    assert_instance_of Ai::OpenAiCompatible, provider
  end

  test "demo streams a reply in chunks and matches the full text" do
    provider = Ai::Demo.new
    chunks = []
    provider.stream([ { role: "user", content: "hello" } ]) { |c| chunks << c }

    joined = chunks.join
    assert joined.present?
    assert_operator chunks.length, :>=, 2
    assert_includes joined.downcase, "emberline"
  end

  test "demo prefixes the reply when the message mentions demo" do
    provider = Ai::Demo.new
    chunks = []
    provider.stream([ { role: "user", content: "demo please" } ]) { |c| chunks << c }
    assert_match(/demo/i, chunks.join)
  end

  test "openai compatible raises a clear error without a key" do
    provider = Ai::OpenAiCompatible.new(config: {}, env: {})
    error = assert_raises(RuntimeError) do
      provider.stream([ { role: "user", content: "hi" } ]) { |_c| }
    end
    assert_includes error.message, "AI_API_KEY"
  end
end
