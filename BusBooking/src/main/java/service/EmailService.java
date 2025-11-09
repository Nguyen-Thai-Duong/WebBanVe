package service;

import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.UnsupportedEncodingException; // <-- Thêm import này
import java.util.Objects;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailService {

    private static final Logger LOGGER = Logger.getLogger(EmailService.class.getName());
    private static final String DEFAULT_SMTP_HOST = "smtp.gmail.com";
    private static final int DEFAULT_SMTP_PORT = 587;
    private static final String SENDER_NAME = "BusBookingSystem"; // <-- Tên người gửi

    private final String username;
    private final String password;

    public EmailService(String username, String password) {
        this.username = Objects.requireNonNull(username, "SMTP username is required");
        this.password = Objects.requireNonNull(password, "SMTP password is required");
    }

    /**
     * Gửi email dạng Plain Text (Hàm gốc của bạn, đã sửa setFrom)
     */
    public boolean sendMail(String to, String subject, String body) {
        Session session = createSession();
        try {
            MimeMessage message = new MimeMessage(session);
            // Sửa: Thêm tên người gửi
            message.setFrom(new InternetAddress(username, SENDER_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");

            // Gửi dạng text
            message.setText(body, "UTF-8");

            Transport.send(message);
            return true;
        } catch (MessagingException | UnsupportedEncodingException ex) { // <-- Thêm UnsupportedEncodingException
            LOGGER.log(Level.SEVERE, "Failed to send text email to " + to, ex);
            return false;
        }
    }

    /**
     * HÀM MỚI: Gửi email dạng HTML
     */
    public boolean sendHtmlMail(String to, String subject, String htmlBody) {
        Session session = createSession();
        try {
            MimeMessage message = new MimeMessage(session);
            // Sửa: Thêm tên người gửi
            message.setFrom(new InternetAddress(username, SENDER_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");

            // THAY ĐỔI QUAN TRỌNG: Gửi dạng HTML
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            LOGGER.log(Level.INFO, "HTML Email sent successfully to {0}", to);
            return true;
        } catch (MessagingException | UnsupportedEncodingException ex) { // <-- Thêm UnsupportedEncodingException
            LOGGER.log(Level.SEVERE, "Failed to send HTML email to " + to, ex);
            return false;
        }
    }

    /**
     * Hàm private để tạo session
     */
    private Session createSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", DEFAULT_SMTP_HOST);
        props.put("mail.smtp.port", String.valueOf(DEFAULT_SMTP_PORT));
        props.put("mail.smtp.ssl.trust", DEFAULT_SMTP_HOST);

        return Session.getInstance(props, new jakarta.mail.Authenticator() {
            @Override
            protected jakarta.mail.PasswordAuthentication getPasswordAuthentication() {
                return new jakarta.mail.PasswordAuthentication(username, password);
            }
        });
    }
}
