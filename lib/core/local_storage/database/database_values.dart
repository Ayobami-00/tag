abstract final class TagDatabaseValues {
  static const aiJobStatuses = [
    'queued',
    'running',
    'awaiting_confirmation',
    'completed',
    'failed',
    'cancelled',
  ];

  static const aiJobTypes = [
    'extract_source',
    'detect_intention',
    'generate_card',
    'generate_suggestion',
    'plan_goal',
    'answer_chat',
    'embed_source',
    'cluster_sources',
  ];

  static const avatarKinds = ['emoji', 'asset', 'image'];
  static const cardCreatedBy = ['ai', 'user', 'chat', 'system'];
  static const cardSourceRoles = [
    'primary',
    'supporting',
    'context',
    'chat_created',
  ];
  static const cardStatuses = [
    'active',
    'completed',
    'snoozed',
    'cancelled',
    'dismissed',
    'archived',
  ];
  static const cardTypes = ['urgent', 'goal', 'suggestion'];
  static const chatPurposes = [
    'general',
    'plan_suggestion',
    'edit_card',
    'edit_space',
    'edit_goal',
    'manual_card',
  ];
  static const chatRoles = ['user', 'assistant', 'system', 'tool'];
  static const chatStatuses = ['active', 'completed', 'archived'];
  static const contentTypes = [
    'message',
    'job_post',
    'article',
    'event',
    'product',
    'travel',
    'unknown',
  ];
  static const feedbackEventTypes = [
    'plan_this',
    'dismiss',
    'complete',
    'snooze',
    'cancel',
    'edit_title',
    'edit_deadline',
    'edit_space',
    'edit_goal_cadence',
    'open_source',
    'view_space',
    'archive',
  ];
  static const goalPlanCreatedBy = ['suggestion', 'chat', 'manual'];
  static const goalPlanStatuses = [
    'draft',
    'active',
    'completed',
    'cancelled',
    'archived',
  ];
  static const notificationPermissionStates = [
    'unknown',
    'granted',
    'denied',
    'provisional',
  ];
  static const notificationStatuses = [
    'pending',
    'scheduled',
    'delivered',
    'cancelled',
    'failed',
  ];
  static const preferenceCategories = [
    'learning',
    'reminders',
    'spaces',
    'wording',
    'privacy',
  ];
  static const sourceProcessingStates = [
    'saved',
    'extracting',
    'extracted',
    'classifying',
    'proposed',
    'completed',
    'failed',
  ];
  static const sourceTypes = [
    'screenshot',
    'image',
    'link',
    'text',
    'chat',
    'saved_post',
    'email_text',
    'manual',
  ];
  static const spaceCreatedBy = ['ai', 'user', 'system'];
  static const spaceTypes = ['specific', 'fallback'];
}
