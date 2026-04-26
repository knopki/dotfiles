export const NotificationPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        await $`notify-send -a OpenCode "Session ended" "Awaiting user's input`;
      }
    },
  };
};
