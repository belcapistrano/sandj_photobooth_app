# Privacy Policy Hosting Guide

This guide helps you host your privacy policy online for App Store submission.

## Quick Setup Checklist

### 1. Customize Your Policy
- [ ] Replace `[YOUR_EMAIL_HERE]` with your actual email address
- [ ] Verify the last updated date is correct
- [ ] Review all content for accuracy

### 2. Choose a Hosting Option
- [ ] Select one of the free hosting services below
- [ ] Upload your HTML file
- [ ] Get the public URL
- [ ] Test the URL in a browser

### 3. Update App Store Listing
- [ ] Add privacy policy URL to your App Store Connect listing
- [ ] Include URL in app submission

## Free Hosting Options

### Option 1: GitHub Pages (Recommended)
**Cost**: Free
**Setup Time**: 5 minutes
**Custom Domain**: Supported

1. **Upload to your existing repository**:
   ```bash
   # The HTML file is already in your repository
   git add privacy_policy.html
   git commit -m "Add privacy policy HTML"
   git push
   ```

2. **Enable GitHub Pages**:
   - Go to repository Settings
   - Scroll to "Pages" section
   - Select "Deploy from a branch"
   - Choose "main" branch
   - Save

3. **Your URL will be**:
   ```
   https://belcapistrano.github.io/sandj_photobooth_app/privacy_policy.html
   ```

### Option 2: Netlify
**Cost**: Free
**Setup Time**: 3 minutes
**Custom Domain**: Supported

1. Go to [netlify.com](https://netlify.com)
2. Drag and drop your `privacy_policy.html` file
3. Get instant URL like: `https://amazing-name-123.netlify.app`

### Option 3: Firebase Hosting
**Cost**: Free
**Setup Time**: 10 minutes
**Custom Domain**: Supported

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Initialize: `firebase init hosting`
3. Deploy: `firebase deploy`

### Option 4: Vercel
**Cost**: Free
**Setup Time**: 5 minutes
**Custom Domain**: Supported

1. Go to [vercel.com](https://vercel.com)
2. Connect your GitHub repository
3. Deploy automatically

### Option 5: Surge.sh
**Cost**: Free
**Setup Time**: 2 minutes
**Custom Domain**: Supported

1. Install: `npm install -g surge`
2. Run: `surge privacy_policy.html`
3. Choose domain name

## Step-by-Step: GitHub Pages Setup

### 1. Enable GitHub Pages
1. Go to: https://github.com/belcapistrano/sandj_photobooth_app/settings/pages
2. Under "Source", select "Deploy from a branch"
3. Choose "main" branch and "/ (root)" folder
4. Click "Save"

### 2. Wait for Deployment
- GitHub will build your site (takes 1-2 minutes)
- You'll see a green checkmark when ready

### 3. Access Your Privacy Policy
Your privacy policy will be available at:
```
https://belcapistrano.github.io/sandj_photobooth_app/privacy_policy.html
```

## Customization Required

### Replace Email Address
Find and replace `[YOUR_EMAIL_HERE]` in both files:

**privacy_policy.html** (line ~180):
```html
<strong>Email:</strong> <a href="mailto:your.email@example.com">your.email@example.com</a>
```

**PRIVACY_POLICY.md** (line ~85):
```markdown
**Email**: your.email@example.com
```

### Update Contact Information
Replace with your actual details:
- Your name (if different from "Bebel Capistrano")
- Your email address
- Any additional contact information

## App Store Integration

### Add to App Store Connect
1. Log into App Store Connect
2. Go to your app's page
3. In "App Information" section
4. Add your privacy policy URL to "Privacy Policy URL" field

### Example URL Format
```
https://belcapistrano.github.io/sandj_photobooth_app/privacy_policy.html
```

## Legal Compliance Checklist

### Required Elements ✅
- [x] Camera access explanation
- [x] Photo library access explanation
- [x] Local storage only statement
- [x] No data collection statement
- [x] Contact information
- [x] Last updated date
- [x] Children's privacy protection
- [x] User rights explanation

### App Store Requirements ✅
- [x] Publicly accessible URL
- [x] Mobile-friendly design
- [x] Clear and readable content
- [x] Contact information included
- [x] Covers all app permissions

## Testing Your Privacy Policy

### Before Submitting to App Store
1. **Test the URL** in multiple browsers
2. **Check mobile responsiveness** on phone/tablet
3. **Verify all links work** (email, GitHub)
4. **Proofread content** for accuracy
5. **Confirm email address** is correct

### Validation Tools
- [W3C HTML Validator](https://validator.w3.org/)
- [Mobile-Friendly Test](https://search.google.com/test/mobile-friendly)

## Future Updates

### When to Update Your Privacy Policy
- App functionality changes
- New permissions added
- Data handling practices change
- Legal requirements change

### How to Update
1. Edit the HTML file
2. Update the "Last Updated" date
3. Re-upload to your hosting service
4. No need to change the URL in App Store

## Troubleshooting

### Common Issues

**GitHub Pages not loading**:
- Check repository is public
- Verify Pages is enabled in settings
- Wait 5-10 minutes for deployment

**URL not working**:
- Ensure file is named exactly `privacy_policy.html`
- Check file is in root directory
- Verify no typos in URL

**Mobile display issues**:
- The HTML includes responsive CSS
- Test on actual mobile devices
- Use browser dev tools to simulate mobile

## Support

If you need help with hosting:
1. Check the hosting service's documentation
2. GitHub Pages: [docs.github.com/pages](https://docs.github.com/en/pages)
3. Contact the hosting provider's support

---

**Your privacy policy is ready!** Choose a hosting option and you'll have a professional, compliant privacy policy URL for your App Store submission.