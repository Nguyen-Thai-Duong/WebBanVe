package service;

import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Objects;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Simple SMTP mail sender using Gmail SMTP (STARTTLS) configuration.
 */
public class EmailService {

    private static final Logger LOGGER = Logger.getLogger(EmailService.class.getName());
    private static final String DEFAULT_SMTP_HOST = "smtp.gmail.com";
    private static final int DEFAULT_SMTP_PORT = 587;

    private final String username;
    private final String password;

    public EmailService(String username, String password) {
        this.username = Objects.requireNonNull(username, "SMTP username is required");
        this.password = Objects.requireNonNull(password, "SMTP password is required");
    }

    public boolean sendMail(String to, String subject, String body) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", DEFAULT_SMTP_HOST);
        props.put("mail.smtp.port", String.valueOf(DEFAULT_SMTP_PORT));
        props.put("mail.smtp.ssl.trust", DEFAULT_SMTP_HOST);

        Session session = Session.getInstance(props, new jakarta.mail.Authenticator() {
            @Override
            protected jakarta.mail.PasswordAuthentication getPasswordAuthentication() {
                return new jakarta.mail.PasswordAuthentication(username, password);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");
            message.setText(body, "UTF-8");
            Transport.send(message);
            return true;
        } catch (MessagingException ex) {
            LOGGER.log(Level.SEVERE, "Failed to send email to " + to, ex);
            return false;
        }
    }
}
