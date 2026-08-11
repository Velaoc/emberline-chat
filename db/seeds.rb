# Emberline Chat demo seed: one confirmed demo account with two conversations
# so the chat shell has something to show on first sign-in. Run with
#   bin/rails db:seed
# Safe to run repeatedly (find_or_create_by).
demo_email = "demo@emberline.chat"
demo_password = "demo-password-123"

user = User.find_or_initialize_by(email: demo_email)
if user.new_record?
  user.password = demo_password
  user.password_confirmation = demo_password
  user.legal_assent = "1"
  user.confirmed_at = Time.current
  user.save!
  puts "Created demo user #{demo_email} / #{demo_password}"
end

unless user.conversations.exists?
  greeting = user.conversations.create!(title: "Welcome to Emberline")
  greeting.messages.create!(role: "user", content: "Hi! What can you do?")
  greeting.messages.create!(role: "assistant", content: "Hello! I'm Emberline. I can hold a conversation, answer questions, and keep every reply inside this thread so you can come back to it later. This demo runs on a canned provider — ask me anything and I'll reply instantly.")

  long = user.conversations.create!(title: "How streaming works")
  long.messages.create!(role: "user", content: "How does the streaming reply work?")
  long.messages.create!(role: "assistant", content: "When you send a message, the server opens one response and keeps it open. The AI provider yields the reply in small chunks, each one is flushed straight to your browser, and the conversation view grows in place — no page reload.\n\nThe full reply is then saved to the database, so if you leave and come back the whole thread is still there, exactly as it streamed.")
  puts "Seeded demo conversations"
end
