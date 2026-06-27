part of '../main.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        if (!auth.initialized) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!auth.isLoggedIn) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const PageIntro(
                title: 'লগইন / নিবন্ধন',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              const InfoCard(
                'অ্যাকাউন্ট সুবিধা',
                'প্রোফাইল দেখা, ঠিকানা সংরক্ষণ এবং ভবিষ্যৎ অনলাইন সেবা ব্যবহারের জন্য অ্যাকাউন্ট তৈরি করুন।',
              ),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('লগইন করুন'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('নিবন্ধন করুন'),
              ),
            ],
          );
        }
        final profile = auth.profile;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PageIntro(title: 'আমার প্রোফাইল', icon: Icons.person_outline),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${text(profile ?? {}, 'first_name')} ${text(profile ?? {}, 'last_name')}'
                          .trim(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    profileRow('ইমেইল', text(profile ?? {}, 'email')),
                    profileRow('মোবাইল', text(profile ?? {}, 'phone')),
                    profileRow('ঠিকানা', text(profile ?? {}, 'street_address')),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => auth.logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('লগআউট'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'প্রদান করা হয়নি' : value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool showPassword = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('লগইন')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageIntro(title: 'লগইন করুন', icon: Icons.login),
          const SizedBox(height: 14),
          if (error.isNotEmpty) ErrorBox(error),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'ইমেইল'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            obscureText: !showPassword,
            decoration: InputDecoration(
              labelText: 'পাসওয়ার্ড',
              suffixIcon: IconButton(
                onPressed: () => setState(() => showPassword = !showPassword),
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: loading
                ? null
                : () async {
                    setState(() {
                      loading = true;
                      error = '';
                    });
                    try {
                      await auth.login(email.text.trim(), password.text);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      setState(
                        () => error = e.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => loading = false);
                    }
                  },
            child: Text(loading ? 'লগইন হচ্ছে...' : 'লগইন'),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> upazilas = [];
  String? district;
  String? upazila;
  String error = '';
  bool loading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    api.list('/madrasha/districts/').then((items) {
      if (mounted) setState(() => districts = items);
    });
  }

  Future<void> loadUpazilas(String districtId) async {
    final items = await api.list(
      '/madrasha/upazilas/',
      query: {'district': districtId},
    );
    if (mounted) {
      setState(() {
        upazilas = items;
        upazila = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('নিবন্ধন')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageIntro(
            title: 'নতুন অ্যাকাউন্ট',
            icon: Icons.person_add_alt_1,
          ),
          const SizedBox(height: 14),
          if (error.isNotEmpty) ErrorBox(error),
          TextField(
            controller: firstName,
            decoration: const InputDecoration(labelText: 'ফার্স্ট নেম'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: lastName,
            decoration: const InputDecoration(labelText: 'লাস্ট নেম'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'মোবাইল'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'ইমেইল'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('district-$district-${districts.length}'),
            initialValue: district,
            decoration: const InputDecoration(labelText: 'জেলা'),
            items: districts
                .map(
                  (item) => DropdownMenuItem(
                    value: '${item['id']}',
                    child: Text(text(item, 'name')),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => district = value);
              if (value != null) loadUpazilas(value);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('upazila-$upazila-${upazilas.length}'),
            initialValue: upazila,
            decoration: const InputDecoration(labelText: 'থানা / উপজেলা'),
            items: upazilas
                .map(
                  (item) => DropdownMenuItem(
                    value: '${item['id']}',
                    child: Text(text(item, 'name')),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => upazila = value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: address,
            decoration: const InputDecoration(
              labelText: 'গ্রাম / রাস্তা / মহল্লা',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: password,
            obscureText: !showPassword,
            decoration: InputDecoration(
              labelText: 'পাসওয়ার্ড',
              suffixIcon: IconButton(
                onPressed: () => setState(() => showPassword = !showPassword),
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: confirm,
            obscureText: !showConfirmPassword,
            decoration:
                const InputDecoration(
                  labelText: 'পাসওয়ার্ড নিশ্চিত করুন',
                ).copyWith(
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => showConfirmPassword = !showConfirmPassword,
                    ),
                    icon: Icon(
                      showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: loading ? null : () => submit(auth),
            child: Text(loading ? 'নিবন্ধন হচ্ছে...' : 'নিবন্ধন করুন'),
          ),
        ],
      ),
    );
  }

  Future<void> submit(AuthStore auth) async {
    if (password.text != confirm.text) {
      setState(() => error = 'পাসওয়ার্ড দুটি মিলছে না');
      return;
    }
    setState(() {
      loading = true;
      error = '';
    });
    try {
      await auth.register({
        'first_name': firstName.text.trim(),
        'last_name': lastName.text.trim(),
        'phone': phone.text.trim(),
        'email': email.text.trim(),
        'district': district == null ? null : int.parse(district!),
        'upazila': upazila == null ? null : int.parse(upazila!),
        'street_address': address.text.trim(),
        'password': password.text,
      }, password.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}
