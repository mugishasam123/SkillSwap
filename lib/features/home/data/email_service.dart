import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  static String get _apiKey => dotenv.env['SENDGRID_API_KEY'] ?? '';
  static const String _fromEmail = 't.egbunike@alustudent.com';
  static const String _fromName = 'SkillSwap Team';

  static Future<void> sendSwapConfirmationEmail({
    required String requesterEmail,
    required String receiverEmail,
    required String requesterName,
    required String receiverName,
    required String requesterLocation,
    required String receiverLocation,
    required String meetingDate,
    required String meetingTime,
    required String platform,
    required String skillToLearn,
  }) async {
    try {
      final url = 'https://api.sendgrid.com/v3/mail/send';
      
      // Create email content
      final emailContent = _createEmailContent(
        requesterName: requesterName,
        receiverName: receiverName,
        requesterLocation: requesterLocation,
        receiverLocation: receiverLocation,
        meetingDate: meetingDate,
        meetingTime: meetingTime,
        platform: platform,
        skillToLearn: skillToLearn,
      );

      // Send email to requester
      final requesterResponse = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {
                  'email': requesterEmail,
                  'name': requesterName,
                }
              ],
              'subject': '🎉 Swap Confirmed: $skillToLearn Session with $receiverName',
            }
          ],
          'from': {
            'email': _fromEmail,
            'name': _fromName,
          },
          'content': [
            {
              'type': 'text/html',
              'value': emailContent,
            }
          ],
        }),
      );

      // Send email to receiver
      final receiverResponse = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {
                  'email': receiverEmail,
                  'name': receiverName,
                }
              ],
              'subject': '🎉 Swap Confirmed: $skillToLearn Session with $requesterName',
            }
          ],
          'from': {
            'email': _fromEmail,
            'name': _fromName,
          },
          'content': [
            {
              'type': 'text/html',
              'value': emailContent,
            }
          ],
        }),
      );

      print('Requester response: ${requesterResponse.statusCode} - ${requesterResponse.body}');
      print('Receiver response: ${receiverResponse.statusCode} - ${receiverResponse.body}');

      if (requesterResponse.statusCode == 202 && receiverResponse.statusCode == 202) {
        print('✅ Confirmation emails sent successfully to both parties!');
        print('📧 Sent to requester: $requesterEmail');
        print('📧 Sent to receiver: $receiverEmail');
      } else {
        print('❌ Error sending emails:');
        print('Requester response: ${requesterResponse.statusCode} - ${requesterResponse.body}');
        print('Receiver response: ${receiverResponse.statusCode} - ${receiverResponse.body}');
        throw Exception('Failed to send confirmation emails');
      }
    } catch (error) {
      print('❌ Error sending confirmation emails: $error');
      throw Exception('Failed to send confirmation emails: $error');
    }
  }

  static String _createEmailContent({
    required String requesterName,
    required String receiverName,
    required String requesterLocation,
    required String receiverLocation,
    required String meetingDate,
    required String meetingTime,
    required String platform,
    required String skillToLearn,
  }) {
    final platformLink = platform == 'Google Meet' 
        ? 'https://meet.google.com' 
        : 'https://zoom.us';

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SkillSwap - Meeting Confirmed!</title>
        <style>
          body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px; }
          .meeting-card { background: white; padding: 25px; margin: 20px 0; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .participant-card { background: #e3f2fd; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #2196f3; }
          .button { display: inline-block; padding: 12px 24px; background: #4caf50; color: white; text-decoration: none; border-radius: 5px; margin: 10px 5px; }
          .tips { background: #fff3e0; padding: 20px; border-radius: 8px; border-left: 4px solid #ff9800; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; }
          .highlight { background: #e8f5e8; padding: 15px; border-radius: 5px; margin: 10px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎉 SkillSwap Meeting Confirmed!</h1>
            <p>Your skill exchange session has been successfully scheduled</p>
          </div>

          <div class="content">
            <div class="highlight">
              <h2>📅 Meeting Details</h2>
              <p><strong>Date:</strong> $meetingDate</p>
              <p><strong>Time:</strong> $meetingTime</p>
              <p><strong>Platform:</strong> $platform</p>
              <p><strong>Skill Focus:</strong> $skillToLearn</p>
            </div>

            <div class="meeting-card">
              <h3>👥 Participants</h3>
              <div class="participant-card">
                <h4>$requesterName (Requester)</h4>
                <p>📍 Location: ${requesterLocation.isEmpty ? 'Not specified' : requesterLocation}</p>
                <p>🎯 Will be learning: $skillToLearn</p>
              </div>
              <div class="participant-card">
                <h4>$receiverName (Receiver)</h4>
                <p>📍 Location: ${receiverLocation.isEmpty ? 'Not specified' : receiverLocation}</p>
                <p>🎯 Will be teaching: $skillToLearn</p>
              </div>
            </div>

            <div class="tips">
              <h3>💡 Preparation Tips</h3>
              <ul>
                <li><strong>Test your setup:</strong> Ensure your camera and microphone work properly</li>
                <li><strong>Prepare your environment:</strong> Find a quiet, well-lit space</li>
                <li><strong>Have materials ready:</strong> Prepare any resources you'll need to share</li>
                <li><strong>Be on time:</strong> Join the meeting 5 minutes early</li>
                <li><strong>Stay engaged:</strong> Ask questions and participate actively</li>
              </ul>
            </div>

            <div style="text-align: center; margin: 30px 0;">
              <a href="$platformLink" class="button" target="_blank">Open $platform</a>
            </div>

            <div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <h3>📋 What to Expect</h3>
              <p>This session is designed to be a collaborative learning experience. Both participants will have the opportunity to:</p>
              <ul>
                <li>Share knowledge and expertise</li>
                <li>Ask questions and get clarification</li>
                <li>Practice and demonstrate skills</li>
                <li>Build meaningful connections</li>
              </ul>
            </div>

            <div style="background: #e8f5e8; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <h3>🔄 After the Meeting</h3>
              <p>Don't forget to:</p>
              <ul>
                <li>Share feedback with each other</li>
                <li>Schedule follow-up sessions if needed</li>
                <li>Update your skill profiles</li>
                <li>Rate your experience in the app</li>
              </ul>
            </div>

            <div class="footer">
              <p><strong>SkillSwap Team</strong></p>
              <p>Building a community of learners and teachers</p>
              <p style="font-size: 12px; color: #999;">If you have any questions or need to reschedule, please contact us through the app.</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    ''';
  }
} 