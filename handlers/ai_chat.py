import logging

from telegram import Update
from telegram.ext import ContextTypes
from telegram.constants import ChatAction

from services.gemini_service import ask_ai

logger = logging.getLogger(__name__)


async def ai_chat(update: Update, context: ContextTypes.DEFAULT_TYPE):

    user = update.effective_user.first_name
    user_id = update.effective_user.id
    user_message = update.message.text

    logger.info(
        f"User: {user} | ID: {user_id} | Message: {user_message}"
    )

    await context.bot.send_chat_action(
        chat_id=update.effective_chat.id,
        action=ChatAction.TYPING
    )

    try:

        response = ask_ai(user_message)

        logger.info(
            f"Bot Reply: {response}"
        )

        await update.message.reply_text(
            response,
            parse_mode="Markdown"
        )

    except Exception as e:

        logger.error(str(e))

        await update.message.reply_text(
            "⚠️ AI service temporarily unavailable."
        )