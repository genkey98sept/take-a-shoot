export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      admin_actions: {
        Row: {
          action_type: Database["public"]["Enums"]["admin_action_type"]
          admin_id: string | null
          created_at: string
          details: Json | null
          id: string
          target_id: string | null
          target_type: string | null
        }
        Insert: {
          action_type: Database["public"]["Enums"]["admin_action_type"]
          admin_id?: string | null
          created_at?: string
          details?: Json | null
          id?: string
          target_id?: string | null
          target_type?: string | null
        }
        Update: {
          action_type?: Database["public"]["Enums"]["admin_action_type"]
          admin_id?: string | null
          created_at?: string
          details?: Json | null
          id?: string
          target_id?: string | null
          target_type?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "admin_actions_admin_id_fkey"
            columns: ["admin_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      blocks: {
        Row: {
          blocked_id: string
          blocker_id: string
          created_at: string
        }
        Insert: {
          blocked_id: string
          blocker_id: string
          created_at?: string
        }
        Update: {
          blocked_id?: string
          blocker_id?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "blocks_blocked_id_fkey"
            columns: ["blocked_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "blocks_blocker_id_fkey"
            columns: ["blocker_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      friend_requests: {
        Row: {
          created_at: string
          id: string
          receiver_id: string
          responded_at: string | null
          sender_id: string
          status: Database["public"]["Enums"]["friend_request_status"]
        }
        Insert: {
          created_at?: string
          id?: string
          receiver_id: string
          responded_at?: string | null
          sender_id: string
          status?: Database["public"]["Enums"]["friend_request_status"]
        }
        Update: {
          created_at?: string
          id?: string
          receiver_id?: string
          responded_at?: string | null
          sender_id?: string
          status?: Database["public"]["Enums"]["friend_request_status"]
        }
        Relationships: [
          {
            foreignKeyName: "friend_requests_receiver_id_fkey"
            columns: ["receiver_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "friend_requests_sender_id_fkey"
            columns: ["sender_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      friendships: {
        Row: {
          created_at: string
          user_high: string
          user_low: string
        }
        Insert: {
          created_at?: string
          user_high: string
          user_low: string
        }
        Update: {
          created_at?: string
          user_high?: string
          user_low?: string
        }
        Relationships: [
          {
            foreignKeyName: "friendships_user_high_fkey"
            columns: ["user_high"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "friendships_user_low_fkey"
            columns: ["user_low"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      moderation_alerts: {
        Row: {
          created_at: string
          details: Json | null
          id: string
          reviewed_at: string | null
          reviewed_by: string | null
          status: Database["public"]["Enums"]["moderation_alert_status"]
          subject_comment_id: string | null
          subject_profile_id: string | null
          subject_shoot_id: string | null
          type: Database["public"]["Enums"]["moderation_alert_type"]
        }
        Insert: {
          created_at?: string
          details?: Json | null
          id?: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: Database["public"]["Enums"]["moderation_alert_status"]
          subject_comment_id?: string | null
          subject_profile_id?: string | null
          subject_shoot_id?: string | null
          type: Database["public"]["Enums"]["moderation_alert_type"]
        }
        Update: {
          created_at?: string
          details?: Json | null
          id?: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: Database["public"]["Enums"]["moderation_alert_status"]
          subject_comment_id?: string | null
          subject_profile_id?: string | null
          subject_shoot_id?: string | null
          type?: Database["public"]["Enums"]["moderation_alert_type"]
        }
        Relationships: [
          {
            foreignKeyName: "moderation_alerts_reviewed_by_fkey"
            columns: ["reviewed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "moderation_alerts_subject_comment_id_fkey"
            columns: ["subject_comment_id"]
            isOneToOne: false
            referencedRelation: "shoot_comments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "moderation_alerts_subject_profile_id_fkey"
            columns: ["subject_profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "moderation_alerts_subject_shoot_id_fkey"
            columns: ["subject_shoot_id"]
            isOneToOne: false
            referencedRelation: "shoots"
            referencedColumns: ["id"]
          },
        ]
      }
      mugshoots: {
        Row: {
          created_at: string
          id: string
          owner_id: string
          processing_status: Database["public"]["Enums"]["processing_status"]
          render_path: string | null
          source_paths: string[] | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          owner_id: string
          processing_status?: Database["public"]["Enums"]["processing_status"]
          render_path?: string | null
          source_paths?: string[] | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          owner_id?: string
          processing_status?: Database["public"]["Enums"]["processing_status"]
          render_path?: string | null
          source_paths?: string[] | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "mugshoots_owner_id_fkey"
            columns: ["owner_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      notification_preferences: {
        Row: {
          comments: boolean
          created_at: string
          friend_accepted: boolean
          friend_requests: boolean
          product_reminders: boolean
          reactions: boolean
          replies: boolean
          tags: boolean
          updated_at: string
          user_id: string
        }
        Insert: {
          comments?: boolean
          created_at?: string
          friend_accepted?: boolean
          friend_requests?: boolean
          product_reminders?: boolean
          reactions?: boolean
          replies?: boolean
          tags?: boolean
          updated_at?: string
          user_id: string
        }
        Update: {
          comments?: boolean
          created_at?: string
          friend_accepted?: boolean
          friend_requests?: boolean
          product_reminders?: boolean
          reactions?: boolean
          replies?: boolean
          tags?: boolean
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "notification_preferences_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          actor_id: string | null
          comment_id: string | null
          created_at: string
          friend_request_id: string | null
          id: string
          read_at: string | null
          recipient_id: string
          shoot_id: string | null
          type: Database["public"]["Enums"]["notification_type"]
        }
        Insert: {
          actor_id?: string | null
          comment_id?: string | null
          created_at?: string
          friend_request_id?: string | null
          id?: string
          read_at?: string | null
          recipient_id: string
          shoot_id?: string | null
          type: Database["public"]["Enums"]["notification_type"]
        }
        Update: {
          actor_id?: string | null
          comment_id?: string | null
          created_at?: string
          friend_request_id?: string | null
          id?: string
          read_at?: string | null
          recipient_id?: string
          shoot_id?: string | null
          type?: Database["public"]["Enums"]["notification_type"]
        }
        Relationships: [
          {
            foreignKeyName: "notifications_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_comment_id_fkey"
            columns: ["comment_id"]
            isOneToOne: false
            referencedRelation: "shoot_comments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_friend_request_id_fkey"
            columns: ["friend_request_id"]
            isOneToOne: false
            referencedRelation: "friend_requests"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_recipient_id_fkey"
            columns: ["recipient_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_shoot_id_fkey"
            columns: ["shoot_id"]
            isOneToOne: false
            referencedRelation: "shoots"
            referencedColumns: ["id"]
          },
        ]
      }
      places: {
        Row: {
          city: string | null
          country_code: string | null
          created_at: string
          created_by: string | null
          id: string
          latitude: number | null
          longitude: number | null
          name: string
          provider: string | null
          provider_place_id: string | null
        }
        Insert: {
          city?: string | null
          country_code?: string | null
          created_at?: string
          created_by?: string | null
          id?: string
          latitude?: number | null
          longitude?: number | null
          name: string
          provider?: string | null
          provider_place_id?: string | null
        }
        Update: {
          city?: string | null
          country_code?: string | null
          created_at?: string
          created_by?: string | null
          id?: string
          latitude?: number | null
          longitude?: number | null
          name?: string
          provider?: string | null
          provider_place_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "places_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_path: string | null
          bio: string | null
          city: string | null
          country_code: string
          created_at: string
          deleted_at: string | null
          first_name: string
          id: string
          status: Database["public"]["Enums"]["account_status"]
          updated_at: string
          username: string
        }
        Insert: {
          avatar_path?: string | null
          bio?: string | null
          city?: string | null
          country_code: string
          created_at?: string
          deleted_at?: string | null
          first_name: string
          id: string
          status?: Database["public"]["Enums"]["account_status"]
          updated_at?: string
          username: string
        }
        Update: {
          avatar_path?: string | null
          bio?: string | null
          city?: string | null
          country_code?: string
          created_at?: string
          deleted_at?: string | null
          first_name?: string
          id?: string
          status?: Database["public"]["Enums"]["account_status"]
          updated_at?: string
          username?: string
        }
        Relationships: []
      }
      reports: {
        Row: {
          created_at: string
          details: string | null
          id: string
          reason: string | null
          reporter_id: string | null
          resolved_at: string | null
          resolved_by: string | null
          status: Database["public"]["Enums"]["report_status"]
          target_comment_id: string | null
          target_profile_id: string | null
          target_shoot_id: string | null
          target_type: Database["public"]["Enums"]["report_target_type"]
        }
        Insert: {
          created_at?: string
          details?: string | null
          id?: string
          reason?: string | null
          reporter_id?: string | null
          resolved_at?: string | null
          resolved_by?: string | null
          status?: Database["public"]["Enums"]["report_status"]
          target_comment_id?: string | null
          target_profile_id?: string | null
          target_shoot_id?: string | null
          target_type: Database["public"]["Enums"]["report_target_type"]
        }
        Update: {
          created_at?: string
          details?: string | null
          id?: string
          reason?: string | null
          reporter_id?: string | null
          resolved_at?: string | null
          resolved_by?: string | null
          status?: Database["public"]["Enums"]["report_status"]
          target_comment_id?: string | null
          target_profile_id?: string | null
          target_shoot_id?: string | null
          target_type?: Database["public"]["Enums"]["report_target_type"]
        }
        Relationships: [
          {
            foreignKeyName: "reports_reporter_id_fkey"
            columns: ["reporter_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reports_resolved_by_fkey"
            columns: ["resolved_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reports_target_comment_id_fkey"
            columns: ["target_comment_id"]
            isOneToOne: false
            referencedRelation: "shoot_comments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reports_target_profile_id_fkey"
            columns: ["target_profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reports_target_shoot_id_fkey"
            columns: ["target_shoot_id"]
            isOneToOne: false
            referencedRelation: "shoots"
            referencedColumns: ["id"]
          },
        ]
      }
      shoot_comments: {
        Row: {
          author_id: string
          body: string
          created_at: string
          deleted_at: string | null
          id: string
          parent_id: string | null
          shoot_id: string
          updated_at: string
        }
        Insert: {
          author_id: string
          body: string
          created_at?: string
          deleted_at?: string | null
          id?: string
          parent_id?: string | null
          shoot_id: string
          updated_at?: string
        }
        Update: {
          author_id?: string
          body?: string
          created_at?: string
          deleted_at?: string | null
          id?: string
          parent_id?: string | null
          shoot_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "shoot_comments_author_id_fkey"
            columns: ["author_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shoot_comments_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "shoot_comments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shoot_comments_shoot_id_fkey"
            columns: ["shoot_id"]
            isOneToOne: false
            referencedRelation: "shoots"
            referencedColumns: ["id"]
          },
        ]
      }
      shoot_media: {
        Row: {
          bytes: number | null
          created_at: string
          height: number | null
          id: string
          kind: Database["public"]["Enums"]["media_kind"]
          position: number | null
          shoot_id: string
          storage_path: string
          width: number | null
        }
        Insert: {
          bytes?: number | null
          created_at?: string
          height?: number | null
          id?: string
          kind: Database["public"]["Enums"]["media_kind"]
          position?: number | null
          shoot_id: string
          storage_path: string
          width?: number | null
        }
        Update: {
          bytes?: number | null
          created_at?: string
          height?: number | null
          id?: string
          kind?: Database["public"]["Enums"]["media_kind"]
          position?: number | null
          shoot_id?: string
          storage_path?: string
          width?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "shoot_media_shoot_id_fkey"
            columns: ["shoot_id"]
            isOneToOne: false
            referencedRelation: "shoots"
            referencedColumns: ["id"]
          },
        ]
      }
      shoot_reactions: {
        Row: {
          created_at: string
          reaction: Database["public"]["Enums"]["shoot_reaction"]
          shoot_id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          reaction: Database["public"]["Enums"]["shoot_reaction"]
          shoot_id: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          reaction?: Database["public"]["Enums"]["shoot_reaction"]
          shoot_id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "shoot_reactions_shoot_id_fkey"
            columns: ["shoot_id"]
            isOneToOne: false
            referencedRelation: "shoots"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shoot_reactions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      shoot_tags: {
        Row: {
          created_at: string
          shoot_id: string
          tagged_user_id: string
        }
        Insert: {
          created_at?: string
          shoot_id: string
          tagged_user_id: string
        }
        Update: {
          created_at?: string
          shoot_id?: string
          tagged_user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "shoot_tags_shoot_id_fkey"
            columns: ["shoot_id"]
            isOneToOne: false
            referencedRelation: "shoots"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shoot_tags_tagged_user_id_fkey"
            columns: ["tagged_user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      shoots: {
        Row: {
          captured_at: string
          city: string | null
          country_code: string | null
          created_at: string
          deleted_at: string | null
          filter: string | null
          id: string
          owner_id: string
          place_id: string | null
          place_label: string | null
          processing_status: Database["public"]["Enums"]["processing_status"]
          published_at: string | null
          render_path: string | null
          template: string
          title: string | null
          updated_at: string
          visibility: Database["public"]["Enums"]["shoot_visibility"]
        }
        Insert: {
          captured_at: string
          city?: string | null
          country_code?: string | null
          created_at?: string
          deleted_at?: string | null
          filter?: string | null
          id?: string
          owner_id: string
          place_id?: string | null
          place_label?: string | null
          processing_status?: Database["public"]["Enums"]["processing_status"]
          published_at?: string | null
          render_path?: string | null
          template?: string
          title?: string | null
          updated_at?: string
          visibility?: Database["public"]["Enums"]["shoot_visibility"]
        }
        Update: {
          captured_at?: string
          city?: string | null
          country_code?: string | null
          created_at?: string
          deleted_at?: string | null
          filter?: string | null
          id?: string
          owner_id?: string
          place_id?: string | null
          place_label?: string | null
          processing_status?: Database["public"]["Enums"]["processing_status"]
          published_at?: string | null
          render_path?: string | null
          template?: string
          title?: string | null
          updated_at?: string
          visibility?: Database["public"]["Enums"]["shoot_visibility"]
        }
        Relationships: [
          {
            foreignKeyName: "shoots_owner_id_fkey"
            columns: ["owner_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shoots_place_id_fkey"
            columns: ["place_id"]
            isOneToOne: false
            referencedRelation: "places"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      accept_friend_request: {
        Args: { p_request_id: string }
        Returns: undefined
      }
      are_friends: { Args: { a: string; b: string }; Returns: boolean }
      can_view_shoot: { Args: { p_shoot_id: string }; Returns: boolean }
      get_public_profile: {
        Args: { p_id: string }
        Returns: {
          avatar_path: string
          first_name: string
          id: string
          username: string
        }[]
      }
      is_blocked: { Args: { a: string; b: string }; Returns: boolean }
      is_email_verified: { Args: never; Returns: boolean }
      is_tagged: {
        Args: { p_shoot_id: string; p_user_id: string }
        Returns: boolean
      }
      owns_shoot: { Args: { p_shoot_id: string }; Returns: boolean }
      search_profiles: {
        Args: { p_query: string }
        Returns: {
          avatar_path: string
          first_name: string
          id: string
          username: string
        }[]
      }
    }
    Enums: {
      account_status: "active" | "suspended" | "deactivated"
      admin_action_type:
        | "content_delete"
        | "content_restore"
        | "account_suspend"
        | "account_reactivate"
        | "report_resolve"
        | "note"
      friend_request_status: "pending" | "accepted" | "declined" | "cancelled"
      media_kind: "source" | "render" | "feed" | "thumbnail"
      moderation_alert_status: "open" | "reviewed" | "dismissed"
      moderation_alert_type:
        | "suspicious_text"
        | "spam"
        | "abnormal_volume"
        | "repeated_reports"
        | "image_risk"
      notification_type:
        | "friend_request"
        | "friend_accepted"
        | "comment"
        | "reply"
        | "reaction"
        | "tag"
        | "product_reminder"
      processing_status: "pending" | "processing" | "ready" | "failed"
      report_status: "open" | "reviewing" | "resolved" | "dismissed"
      report_target_type: "shoot" | "comment" | "profile"
      shoot_reaction: "love" | "fire" | "wow" | "haha" | "cool"
      shoot_visibility: "friends"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      account_status: ["active", "suspended", "deactivated"],
      admin_action_type: [
        "content_delete",
        "content_restore",
        "account_suspend",
        "account_reactivate",
        "report_resolve",
        "note",
      ],
      friend_request_status: ["pending", "accepted", "declined", "cancelled"],
      media_kind: ["source", "render", "feed", "thumbnail"],
      moderation_alert_status: ["open", "reviewed", "dismissed"],
      moderation_alert_type: [
        "suspicious_text",
        "spam",
        "abnormal_volume",
        "repeated_reports",
        "image_risk",
      ],
      notification_type: [
        "friend_request",
        "friend_accepted",
        "comment",
        "reply",
        "reaction",
        "tag",
        "product_reminder",
      ],
      processing_status: ["pending", "processing", "ready", "failed"],
      report_status: ["open", "reviewing", "resolved", "dismissed"],
      report_target_type: ["shoot", "comment", "profile"],
      shoot_reaction: ["love", "fire", "wow", "haha", "cool"],
      shoot_visibility: ["friends"],
    },
  },
} as const

